//
//  Constants.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Vapor

enum EnvironmentError: Error {
  case invalidVariable(EnvKey)
}

enum EnvKey: String {
  case shortFetchInterval = "SHORT_FETCH_INTERVAL"
  case longFetchInterval = "LONG_FETCH_INTERVAL"
  case liveMatchURL = "LIVE_MATCH_URL"
  case mapsURL = "MAPS_URL"
  case slackWebhookURL = "SLACK_WEBHOOK_URL"
  case standingsURL = "STANDINGS_URL"
}

extension Environment {
  static func get(_ key: EnvKey) -> String? {
    return get(key.rawValue)
  }

  static func timeInterval(for key: EnvKey) throws -> TimeInterval {
    guard let intervalString = get(key),
      let interval = TimeInterval(intervalString),
      interval > 0 else {
        throw EnvironmentError.invalidVariable(key)
    }
    return interval
  }

  static func url(for key: EnvKey) throws -> URL {
    guard let urlString = get(key),
      let url = URL(string: urlString) else {
        throw EnvironmentError.invalidVariable(key)
    }
    return url
  }
}
