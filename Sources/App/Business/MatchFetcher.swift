//
//  MatchFetcher.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Vapor

enum FetcherError: Error {
  case missingEnvVariable(EnvKey)
  case badResponseCode
}

enum FetchFrequency {
  case short, long
}

extension FetchFrequency {
  var envKey: EnvKey {
    switch self {
    case .short:
      return .shortFetchInterval
    case .long:
      return .longFetchInterval
    }
  }

  func timeAmount() throws -> TimeAmount {
    let interval = try Environment.timeInterval(for: envKey)
    return .seconds(TimeAmount.Value(interval))
  }
}

final class MatchFetcher {
  private let container: Container
  private let eventLoopGroup: EventLoopGroup
  private let publisher: EventPublisher

  private var previousResponse: PartialMatchResponseType?
  private var previousResponseDate: Date?
  private var maps: [OWLMap] = []
  private var standingsTeams: [OWLStandingsTeam] = []

  private var currentTask: RepeatedTask?
  private var currentFetchFrequency = FetchFrequency.short

  private var eventLoop: EventLoop {
    return eventLoopGroup.next()
  }

  init(container: Container) {
    self.container = container
    publisher = EventPublisher(container: container)
    eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  }

  deinit {
    try? eventLoopGroup.syncShutdownGracefully()
  }

  func startFetching() throws {
    try startFetching(with: currentFetchFrequency)
  }

  // MARK: - Helpers

  private func startFetching(with frequency: FetchFrequency) throws {
    let time = try frequency.timeAmount()
    currentFetchFrequency = frequency
    currentTask?.cancel()

    print("switching to fetch frequency: \(frequency), seconds: \(time.seconds)")
    currentTask = eventLoop.scheduleRepeatedTask(initialDelay: time, delay: time) { [weak self] _ in
      try self?.fetchLiveMatch()
      try self?.fetchURL(for: .standingsURL) { (response: OWLStandingsResponse) in
        self?.standingsTeams = response.data
      }
      try self?.fetchURL(for: .mapsURL) { maps in
        self?.maps = maps
      }
    }
  }

  private func fetchURL<T: Decodable>(for key: EnvKey, onSuccess: @escaping (T) -> Void) throws {
    guard let urlString = Environment.get(key),
      let url = URL(string: urlString) else {
        throw FetcherError.missingEnvVariable(key)
    }

    let client = try container.client()
    client.getJSON(url)
      .mapSuccessfulResponseCode()
      .flatMap { try $0.content.decode(T.self) }
      .hopTo(eventLoop: eventLoop)
      .catch { error in
        print("error fetching url: \(url), error: \(error)")
      }
      .whenSuccess(onSuccess)
  }

  private func fetchLiveMatch() throws {
    guard let urlString = Environment.get(.liveMatchURL),
      let url = URL(string: urlString) else {
        throw FetcherError.missingEnvVariable(.liveMatchURL)
    }

    let client = try container.client()
    client.getJSON(url)
      .mapSuccessfulResponseCode()
      .decodeLiveMatch()
      .hopTo(eventLoop: eventLoop)
      .catch { error in
        print("error fetching live match: \(error)")
      }
      .whenSuccess { [weak self] response in
        self?.handleLiveMatchResponse(response)
      }
  }

  private func handleLiveMatchResponse(_ response: PartialMatchResponseType) {
    defer {
      previousResponse = response
      previousResponseDate = Date()
    }

    try? toggleFetchFrequenciesIfNecessary(for: response)

    guard
      let previous = previousResponse,
      let previousDate = previousResponseDate,
      let event = MatchEventBuilder.buildMatchEventWith(
        currentResponse: response,
        previousResponse: previous,
        maps: maps,
        standingsTeams: standingsTeams,
        previousResponseDate: previousDate
      ) else { return }

    print(event.description)
    try? publisher.publish(event: event)
  }

  /// Toggles between fetch frequencies based on the presence of a live match
  /// in the response. If there is no live match, we shouldn't fetch as
  /// frequently.
  ///
  /// - Parameter response: The latest response from the live match endpoint
  private func toggleFetchFrequenciesIfNecessary(for response: PartialMatchResponseType) throws {
    if response.liveMatch == nil && currentFetchFrequency == .short {
      try startFetching(with: .long)
    } else if response.liveMatch != nil && currentFetchFrequency == .long {
      try startFetching(with: .short)
    }
  }
}

extension Future where T == Response {
  func mapSuccessfulResponseCode() -> Future<T> {
    return map { response in
      if (200..<300).contains(response.http.status.code) {
        return response
      } else {
        throw FetcherError.badResponseCode
      }
    }
  }

  func decodeLiveMatch() -> Future<PartialMatchResponseType> {
    return flatMap { response in
      return try response.content
        .decode(OWLLiveMatchResponse.self)
        .map { $0 as PartialMatchResponseType }
        .catchFlatMap { _ in
          try response.content
            .decode(OWLHalfStubResponse.self)
            .map { $0 as PartialMatchResponseType }
        }
        .catchFlatMap { _ in
          try response.content
            .decode(OWLFullStubResponse.self)
            .map { $0 as PartialMatchResponseType }
        }
    }
  }
}

extension Client {
  func getJSON(_ url: URLRepresentable) -> Future<Response> {
    return get(url, headers: ["accept": "application/json"]) { (request) in
      // this was being set to 0 for some reason
      request.http.headers.remove(name: .contentLength)
    }
  }
}

extension TimeAmount {
  var seconds: Int {
    return nanoseconds / 1000 / 1000 / 1000
  }
}
