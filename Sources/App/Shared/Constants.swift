//
//  Constants.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Vapor

enum EnvKey: String {
  case fetchInterval = "FETCH_INTERVAL"
  case liveMatchURL = "LIVE_MATCH_URL"
  case mapsURL = "MAPS_URL"
  case slackWebhookURL = "SLACK_WEBHOOK_URL"
}

extension Environment {
  static func get(_ key: EnvKey) -> String? {
    return get(key.rawValue)
  }
}
