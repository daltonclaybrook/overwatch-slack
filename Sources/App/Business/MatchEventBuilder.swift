//
//  MatchEventBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

struct MatchEventBuilder {
  private static let tenMinutes: TimeInterval = 600

  private init() {}

  static func buildMatchEventWith(currentResponse: OWLResponse, previousResponse: OWLResponse, previousResponseDate: Date) -> MatchEvent? {
    guard let match = currentResponse.data.liveMatch,
      let previous = previousResponse.data.liveMatch,
      let teams = makeTeams(with: match) else {
      return nil
    }

    if let event = matchStartingOrStarted(current: match, previous: previous, previousDate: previousResponseDate, teams: teams) {
      return event
    }

    return nil
  }

  // MARK: - Individual Events

  private static func matchStartingOrStarted(current: OWLResponseMatch, previous: OWLResponseMatch, previousDate: Date, teams: MatchTeams) -> MatchEvent? {
    let previousTimeToStart = current.startDate.timeIntervalSince(previousDate)
    let timeToStart = current.startDate.timeIntervalSinceNow

    if timeToStart <= tenMinutes && previousTimeToStart > tenMinutes {
      return .matchStartingSoon(teams)
    } else if timeToStart <= 0 && previousTimeToStart > 0 {
      return .matchStarted(teams)
    } else {
      return nil
    }
  }

  // MARK: - Helpers

  private static func makeTeams(with match: OWLResponseMatch) -> MatchTeams? {
    guard match.competitors.count >= 2 else { return nil }
    return MatchTeams(
      team1: match.competitors[0],
      team2: match.competitors[1]
    )
  }
}
