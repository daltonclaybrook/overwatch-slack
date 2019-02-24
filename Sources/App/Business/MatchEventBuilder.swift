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

  static func buildMatchEventWith(currentResponse: OWLResponse, previousResponse: OWLResponse, maps: [OWLMap], previousResponseDate: Date) -> MatchEvent? {
    guard let current = currentResponse.data.liveMatch,
      let previous = previousResponse.data.liveMatch,
      let teams = makeTeams(with: current) else {
      return nil
    }

    if let event = matchStartingOrStarted(current: current, previous: previous, previousDate: previousResponseDate, teams: teams) {
      return event
    } else if let event = gameStarted(current: current, previous: previous, teams: teams, maps: maps) {
      return event
    } else if let event = matchEnded(current: current, previous: previous, teams: teams) {
      return event
    } else if let event = gameEnded(current: current, previous: previous, teams: teams) {
      return event
    } else {
      return nil
    }
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

  private static func gameStarted(current: OWLResponseMatch, previous: OWLResponseMatch, teams: MatchTeams, maps: [OWLMap]) -> MatchEvent? {
    guard let inProgressIndex = current.games.firstIndex(where: { $0.status == .inProgress }) else {
      return nil
    }

    let game = current.games[inProgressIndex]
    let map = mapForGame(game, in: maps)
    guard previous.games.count > inProgressIndex else {
      // this game didn't exist previously
      return .gameStarted(teams, gameIndex: inProgressIndex, map)
    }

    let previousGame = previous.games[inProgressIndex]
    if previousGame.status == .pending {
      return .gameStarted(teams, gameIndex: inProgressIndex, map)
    } else {
      return nil
    }
  }

  private static func matchEnded(current: OWLResponseMatch, previous: OWLResponseMatch, teams: MatchTeams) -> MatchEvent? {
    if current.status == .concluded && previous.status == .inProgress {
      return .matchEnded(teams)
    } else {
      return nil
    }
  }

  private static func gameEnded(current: OWLResponseMatch, previous: OWLResponseMatch, teams: MatchTeams) -> MatchEvent? {
    guard let previousInProgressIndex = previous.games.firstIndex(where: { $0.status == .inProgress }),
      current.games.count > previousInProgressIndex else {
      return nil
    }

    let game = current.games[previousInProgressIndex]
    if game.status == .concluded {
      return .gameEnded(teams)
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

  private static func mapForGame(_ game: OWLResponseGame, in maps: [OWLMap]) -> OWLMap? {
    return maps.first { $0.guid == game.attributes.mapGuid }
  }
}
