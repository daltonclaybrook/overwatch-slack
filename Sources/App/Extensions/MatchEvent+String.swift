//
//  MatchEvent+String.swift
//  App
//
//  Created by Dalton Claybrook on 3/11/19.
//

import Foundation

extension MatchEvent: CustomStringConvertible {
  var description: String {
    switch self {
    case .matchStartingSoon(let teams):
      return "match starting soon: \(teams.description)"
    case .matchStarted(let info):
      return "match started: \(info.teams.description)"
    case .mapStarted(let teams, let mapIndex, let map):
      return "map \(mapIndex + 1) started (\(map.englishName.lowercased())): \(teams.description)"
    case .matchEnded(let outcome):
      return "match ended: \(outcome.match.winnerName) > \(outcome.match.loserName) (\(outcome.match.scoreString))"
    case .mapEnded(let outcome, let mapIndex):
      return "map \(mapIndex + 1) ended (\(outcome.map.englishName)): \(outcome.scoreString) \(outcome.winnerNameOrDraw)"
    case .pointsUpdated(let teams):
      return "points updated: \(teams.description)"
    }
  }
}

extension Teams: CustomStringConvertible {
  var description: String {
    return "\(team1.name) vs \(team2.name)"
  }
}
