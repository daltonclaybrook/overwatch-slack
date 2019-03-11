//
//  EventPublisher.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Vapor

enum EventPublisherError: Error {
  case noPublishURL
}

final class EventPublisher {
  private let container: Container

  init(container: Container) {
    self.container = container
  }

  func publish(event: MatchEvent) throws {
    guard let slackURLString = Environment.get(.slackWebhookURL),
      let slackURL = URL(string: slackURLString) else {
        throw EventPublisherError.noPublishURL
    }

    let client = try container.client()
    let body = try event.message.payloadData()
    let httpRequest = HTTPRequest(
      method: .POST,
      url: slackURL,
      headers: ["content-type": "application/json"],
      body: body
    )
    let request = Request(http: httpRequest, using: container)
    client.send(request).whenComplete {}
  }
}

private struct EventPayload: Encodable {
  let text: String
}
