//
//  MatchEventBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

struct MatchChanges {
  let current: OWLLiveMatch
  let previous: OWLLiveMatch
}

extension MatchChanges {
  init?(current: OWLLiveMatch?, previous: OWLLiveMatch?) {
    guard let current = current,
      let previous = previous else { return nil }
    self.init(current: current, previous: previous)
  }
}

struct MatchEventBuilder {
  private let tenMinutes: TimeInterval = 600

  private let liveChanges: MatchChanges
  private let nextChanges: MatchChanges?
  private let teams: Teams
  private let standings: TeamsStandings
  private let maps: [OWLMap]
  private let previousResponseDate: Date

  init?(
    currentResponse: PartialMatchResponseType,
    previousResponse: PartialMatchResponseType,
    maps: [OWLMap],
    standingsTeams: [OWLStandingsTeam],
    previousResponseDate: Date
  ) {
    guard let current = currentResponse.liveMatch,
      let previous = previousResponse.liveMatch,
      let teams = MatchEventBuilder.makeTeams(with: current),
      let standings = MatchEventBuilder.teamsStandings(for: teams, standings: standingsTeams)
    else { return nil }

    self.liveChanges = MatchChanges(current: current, previous: previous)
    self.nextChanges = MatchChanges(current: currentResponse.nextMatch, previous: previousResponse.nextMatch)
    self.teams = teams
    self.standings = standings
    self.maps = maps
    self.previousResponseDate = previousResponseDate
  }

  func buildMatchEvent() -> MatchEvent? {
    if let event = matchStartingOrStarted() {
      return event
    } else if let event = gameStarted() {
      return event
    } else if let event = matchEnded() {
      return event
    } else if let event = gameEnded() {
      return event
    } else {
      return nil
    }
  }

  // MARK: - Individual Events

  private func matchStartingOrStarted() -> MatchEvent? {
    let liveMatchStartsSoon = matchStartsSoon(liveChanges.current, previousDate: previousResponseDate)

    if liveChanges.current.status == .inProgress &&
      liveChanges.previous.status == .pending {
      let info = MatchStartInfo(teams: teams, standings: standings, startDate: liveChanges.current.startDate)
      return .matchStarted(info)
    } else if liveMatchStartsSoon {
      return .matchStartingSoon(teams)
    } else {
      return nil
    }
  }

  private func gameStarted() -> MatchEvent? {
    guard let inProgressIndex = liveChanges.current.games.firstIndex(where: { $0.status == .inProgress }) else {
      return nil
    }

    let game = liveChanges.current.games[inProgressIndex]
    guard let map = mapForGame(game) else { return nil }

    guard liveChanges.previous.games.count > inProgressIndex else {
      // this game didn't exist previously
      return .mapStarted(teams, mapIndex: inProgressIndex, map)
    }

    let previousGame = liveChanges.previous.games[inProgressIndex]
    if previousGame.status == .pending {
      return .mapStarted(teams, mapIndex: inProgressIndex, map)
    } else {
      return nil
    }
  }

  private func matchEnded() -> MatchEvent? {
    if liveChanges.current.status == .concluded &&
			liveChanges.previous.status == .inProgress &&
			liveChanges.current.scores.count == 2 &&
			liveChanges.current.scores[0] != liveChanges.current.scores[1] {

			let team1 = TeamScore(team: teams.team1, score: liveChanges.current.scores[0].value)
			let team2 = TeamScore(team: teams.team2, score: liveChanges.current.scores[1].value)

      let winner = team1.score > team2.score ? team1 : team2
      let loser = team1.score > team2.score ? team2 : team1
      let winningOutcome = WinningOutcome(winner: winner, loser: loser)
      let mapOutcomes = makeAllMapOutcomes(for: liveChanges.current, teams: teams, maps: maps)

      return .matchEnded(MatchOutcome(match: winningOutcome, maps: mapOutcomes))
    } else {
      return nil
    }
  }

  private func gameEnded() -> MatchEvent? {
    guard let previousInProgressIndex = liveChanges.previous.games.firstIndex(where: { $0.status == .inProgress }),
      liveChanges.current.games.count > previousInProgressIndex else {
      return nil
    }

    let game = liveChanges.current.games[previousInProgressIndex]
    if game.status == .concluded,
      let outcome = makeMapOutcome(for: game) {
      return .mapEnded(outcome, mapIndex: previousInProgressIndex)
    } else {
      return nil
    }
  }

  // MARK: - Helpers

  private func matchStartsSoon(_ match: OWLLiveMatch, previousDate: Date) -> Bool {
    let previousTimeToStart = match.startDate.timeIntervalSince(previousDate)
    let currentTimeToStart = match.startDate.timeIntervalSinceNow
    return currentTimeToStart <= tenMinutes && previousTimeToStart > tenMinutes
  }

  private func makeAllMapOutcomes(for match: OWLLiveMatch, teams: Teams, maps: [OWLMap]) -> [MapOutcome] {
    return match.games.compactMap {
      makeMapOutcome(for: $0)
    }
  }

  private func mapForGame(_ game: OWLGame) -> OWLMap? {
    return maps.first { $0.guid == game.attributes.mapGuid }
  }

  private func makeMapOutcome(for game: OWLGame) -> MapOutcome? {
    guard
      let map = mapForGame(game),
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

extension MatchEventBuilder {
  private static func makeTeams(with match: OWLLiveMatch) -> Teams? {
    guard match.competitors.count >= 2 else { return nil }
    return Teams(
      team1: match.competitors[0],
      team2: match.competitors[1]
    )
  }

  private static func teamsStandings(for teams: Teams, standings: [OWLStandingsTeam]) -> TeamsStandings? {
    guard
      let team1 = standings.first(where: { $0.id == teams.team1.id }),
      let team2 = standings.first(where: { $0.id == teams.team2.id })
      else { return nil }
    return TeamsStandings(team1: team1, team2: team2)
  }
}
