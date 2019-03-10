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

final class MatchFetcher {
  private let container: Container
  private let eventLoopGroup: EventLoopGroup
  private let publisher: EventPublisher

  private var previousResponse: OWLResponse?
  private var previousResponseDate: Date?
  private var maps: [OWLMap] = []
  private var standingsTeams: [OWLStandingsTeam] = []

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
    guard let intervalString = Environment.get(.fetchInterval),
      let interval = TimeAmount.Value(intervalString),
      interval > 0 else {
        throw FetcherError.missingEnvVariable(.fetchInterval)
    }

    eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(interval)) { [weak self] _ in
      try self?.fetchURL(for: .liveMatchURL) { response in
        self?.handleLiveMatchResponse(response)
      }
      try self?.fetchURL(for: .standingsURL) { (response: OWLStandingsResponse) in
        self?.standingsTeams = response.data
      }
      try self?.fetchURL(for: .mapsURL) { maps in
        self?.maps = maps
      }
    }
  }

  // MARK: - Helpers

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
        print("caught error: \(error)")
      }
      .whenSuccess(onSuccess)
  }

  private func handleLiveMatchResponse(_ response: OWLResponse) {
    defer {
      previousResponse = response
      previousResponseDate = Date()
    }

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

    print(event)
    try? publisher.publish(event: event)
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
}

extension Client {
  func getJSON(_ url: URLRepresentable) -> Future<Response> {
    return get(url, headers: ["accept": "application/json"]) { (request) in
      // this was being set to 0 for some reason
      request.http.headers.remove(name: .contentLength)
    }
  }
}
