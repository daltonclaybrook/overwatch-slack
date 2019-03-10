//
//  MatchEvent.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

enum MatchEvent {
  // ten minutes
  case matchStartingSoon(Teams)
  // only one of these events will fire at a time,
  // whichever is most significant
  case matchStarted(MatchStartInfo)
  case mapStarted(Teams, mapIndex: Int, OWLMap)

  // only one of these events will fire at a time,
  // whichever is most significant
  case matchEnded(MatchOutcome)
  case mapEnded(MapOutcome, mapIndex: Int)

  case pointsUpdated(Teams)
}

// MARK: - Supporting Models

struct Teams {
  let team1: OWLResponseCompetitor
  let team2: OWLResponseCompetitor
}

struct TeamsStandings {
  let team1: OWLStandingsTeam
  let team2: OWLStandingsTeam
}

struct MatchStartInfo {
  let teams: Teams
  let standings: TeamsStandings
  let startDate: Date
}

struct RoundStartedInfo {
  let teams: Teams
  // may not be one offensive team, such as on control maps
  let offense: OWLResponseCompetitor?
  let isNewGame: Bool
  let isNewMatch: Bool
}

struct TeamScore {
	let team: OWLResponseCompetitor
	let score: Int
}

struct WinningOutcome {
	let winner: TeamScore
	let loser: TeamScore
}

enum MapOutcome {
  case win(OWLMap, WinningOutcome)
	case draw(OWLMap, Teams, score: Int)
}

struct MatchOutcome {
  let match: WinningOutcome
  let maps: [MapOutcome]
}

extension MapOutcome {
  var map: OWLMap {
    switch self {
    case .win(let map, _):
      return map
    case .draw(let map, _, _):
      return map
    }
  }

  /// e.g. "3-2"
  var scoreString: String {
    switch self {
    case .win(_, let outcome):
      return outcome.scoreString
    case .draw(_, _, let score):
      return "\(score)-\(score)"
    }
  }

  var winnerNameOrDraw: String {
    switch self {
    case .win(_, let outcome):
      return "\(outcome.winnerName)"
    case .draw:
      return "Draw"
    }
  }
}

extension WinningOutcome {
  var winnerName: String {
    return winner.team.name
  }

  var loserName: String {
    return loser.team.name
  }

  /// e.g. "3-2"
  var scoreString: String {
    return "\(winner.score)-\(loser.score)"
  }
}
