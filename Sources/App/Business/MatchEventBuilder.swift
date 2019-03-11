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

  static func buildMatchEventWith(
    currentResponse: OWLResponse,
    previousResponse: OWLResponse,
    maps: [OWLMap],
    standingsTeams: [OWLStandingsTeam],
    previousResponseDate: Date
  ) -> MatchEvent? {
    guard let current = currentResponse.data.liveMatch,
      let previous = previousResponse.data.liveMatch,
      let teams = makeTeams(with: current),
      let standings = teamsStandings(for: teams, standings: standingsTeams) else {
      return nil
    }

    if let event = matchStartingOrStarted(current: current, previous: previous, previousDate: previousResponseDate, teams: teams, standings: standings) {
      return event
    } else if let event = gameStarted(current: current, previous: previous, teams: teams, maps: maps) {
      return event
    } else if let event = matchEnded(current: current, previous: previous, teams: teams, maps: maps) {
      return event
    } else if let event = gameEnded(current: current, previous: previous, teams: teams, maps: maps) {
      return event
    } else {
      return nil
    }
  }

  // MARK: - Individual Events

  private static func matchStartingOrStarted(
    current: OWLResponseMatch,
    previous: OWLResponseMatch,
    previousDate: Date,
    teams: Teams,
    standings: TeamsStandings
  ) -> MatchEvent? {
    let previousTimeToStart = current.startDate.timeIntervalSince(previousDate)
    let timeToStart = current.startDate.timeIntervalSinceNow

    if current.status == .inProgress && previous.status == .pending {
      let info = MatchStartInfo(teams: teams, standings: standings, startDate: current.startDate)
      return .matchStarted(info)
    } else if timeToStart <= tenMinutes && previousTimeToStart > tenMinutes {
      return .matchStartingSoon(teams)
    } else {
      return nil
    }
  }

  private static func gameStarted(current: OWLResponseMatch, previous: OWLResponseMatch, teams: Teams, maps: [OWLMap]) -> MatchEvent? {
    guard let inProgressIndex = current.games.firstIndex(where: { $0.status == .inProgress }) else {
      return nil
    }

    let game = current.games[inProgressIndex]
    guard let map = mapForGame(game, in: maps) else { return nil }

    guard previous.games.count > inProgressIndex else {
      // this game didn't exist previously
      return .mapStarted(teams, mapIndex: inProgressIndex, map)
    }

    let previousGame = previous.games[inProgressIndex]
    if previousGame.status == .pending {
      return .mapStarted(teams, mapIndex: inProgressIndex, map)
    } else {
      return nil
    }
  }

  private static func matchEnded(current: OWLResponseMatch, previous: OWLResponseMatch, teams: Teams, maps: [OWLMap]) -> MatchEvent? {
    if current.status == .concluded &&
			previous.status == .inProgress &&
			current.scores.count == 2 &&
			current.scores[0] != current.scores[1] {

			let team1 = TeamScore(team: teams.team1, score: current.scores[0].value)
			let team2 = TeamScore(team: teams.team2, score: current.scores[1].value)

      let winner = team1.score > team2.score ? team1 : team2
      let loser = team1.score > team2.score ? team2 : team1
      let winningOutcome = WinningOutcome(winner: winner, loser: loser)
      let mapOutcomes = makeAllMapOutcomes(for: current, teams: teams, maps: maps)

      return .matchEnded(MatchOutcome(match: winningOutcome, maps: mapOutcomes))
    } else {
      return nil
    }
  }

  private static func gameEnded(current: OWLResponseMatch, previous: OWLResponseMatch, teams: Teams, maps: [OWLMap]) -> MatchEvent? {
    guard let previousInProgressIndex = previous.games.firstIndex(where: { $0.status == .inProgress }),
      current.games.count > previousInProgressIndex else {
      return nil
    }

    let game = current.games[previousInProgressIndex]
    if game.status == .concluded,
      let outcome = makeMapOutcome(for: game, teams: teams, maps: maps) {
      return .mapEnded(outcome, mapIndex: previousInProgressIndex)
    } else {
      return nil
    }
  }

  // MARK: - Helpers

  private static func makeTeams(with match: OWLResponseMatch) -> Teams? {
    guard match.competitors.count >= 2 else { return nil }
    return Teams(
      team1: match.competitors[0],
      team2: match.competitors[1]
    )
  }

  private static func makeAllMapOutcomes(for match: OWLResponseMatch, teams: Teams, maps: [OWLMap]) -> [MapOutcome] {
    return match.games.compactMap {
      makeMapOutcome(for: $0, teams: teams, maps: maps)
    }
  }

  private static func mapForGame(_ game: OWLResponseGame, in maps: [OWLMap]) -> OWLMap? {
    return maps.first { $0.guid == game.attributes.mapGuid }
  }

  private static func teamsStandings(for teams: Teams, standings: [OWLStandingsTeam]) -> TeamsStandings? {
    guard
      let team1 = standings.first(where: { $0.id == teams.team1.id }),
      let team2 = standings.first(where: { $0.id == teams.team2.id })
    else { return nil }
    return TeamsStandings(team1: team1, team2: team2)
  }

  private static func makeMapOutcome(for game: OWLResponseGame, teams: Teams, maps: [OWLMap]) -> MapOutcome? {
    guard
      let map = mapForGame(game, in: maps),
      let points = game.points,
      points.count == 2
    else { return nil }

    let team1 = TeamScore(team: teams.team1, score: points[0])
    let team2 = TeamScore(team: teams.team2, score: points[1])

    if team1.score == team2.score {
      return .draw(map, teams, score: team1.score)
    } else if team1.score > team2.score {
      return .win(map, WinningOutcome(winner: team1, loser: team2))
    } else {
      return .win(map, WinningOutcome(winner: team2, loser: team1))
    }
  }
}
