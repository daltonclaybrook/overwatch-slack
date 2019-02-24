//
//  MatchFetcher.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Vapor

enum FetcherError: Error {
  case missingIntervalVariable
  case missingLiveMatchURLVariable
  case missingMapsURLVariable
  case badResponseCode
}

final class MatchFetcher {
  private let container: Container
  private let eventLoopGroup: EventLoopGroup
  private let publisher: EventPublisher

  private var previousResponse: OWLResponse?
  private var previousResponseDate: Date?
  private var maps: [OWLMap] = []

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
        throw FetcherError.missingIntervalVariable
    }

    try fetchMaps()
    eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(interval)) { [weak self] _ in
      try self?.fetch()
    }
  }

  // MARK: - Helpers

  private func fetchMaps() throws {
    guard let mapsURLString = Environment.get(.mapsURL),
      let mapsURL = URL(string: mapsURLString) else {
        throw FetcherError.missingMapsURLVariable
    }

    let client = try container.client()
    client.get(mapsURL, headers: ["accept": "application/json"]) { (request) in
        // this was being set to 0 for some reason
        request.http.headers.remove(name: .contentLength)
      }
      .flatMap { try $0.content.decode([OWLMap].self) }
      .hopTo(eventLoop: eventLoop)
      .catch { error in
        print("error fetching maps:\n\(error)")
      }
      .whenSuccess { [weak self] maps in
        self?.maps = maps
      }
  }

  private func fetch() throws {
    guard let urlString = Environment.get(.liveMatchURL),
      let url = URL(string: urlString) else {
        throw FetcherError.missingLiveMatchURLVariable
    }
    let client = try container.client()

    client
      .get(url, headers: ["accept": "application/json"]) { (request) in
        // this was being set to 0 for some reason
        request.http.headers.remove(name: .contentLength)
      }
      .map { response -> Response in
        if (200..<300).contains(response.http.status.code) {
          return response
        } else {
          throw FetcherError.badResponseCode
        }
      }
      .flatMap { response -> EventLoopFuture<OWLResponse> in
        return try response.content.decode(OWLResponse.self)
          .mapIfError { error in
            print(error)
            return .empty()
          }
      }
      .hopTo(eventLoop: eventLoop)
      .catch { error in
        print("caught error: \(error)")
      }
      .whenSuccess { [weak self] response in
        self?.handleResponse(response)
      }
  }

  private func handleResponse(_ response: OWLResponse) {
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
        previousResponseDate: previousDate
      ) else { return }

    print(event)
    try? publisher.publish(event: event)
  }
}
