//
//  MatchEvent.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

struct MatchTeams {
  let team1: OWLResponseCompetitor
  let team2: OWLResponseCompetitor
}

struct RoundStartedInfo {
  let teams: MatchTeams
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

enum Outcome {
  case win(WinningOutcome)
	case draw(MatchTeams, score: Int)
}

enum MatchEvent {
  // ten minutes
  case matchStartingSoon(MatchTeams)
  // only one of these events will fire at a time,
  // whichever is most significant
  case matchStarted(MatchTeams)
  case gameStarted(MatchTeams, gameIndex: Int, OWLMap?)

  // only one of these events will fire at a time,
  // whichever is most significant
	case matchEnded(WinningOutcome)
	case gameEnded(Outcome, gameIndex: Int)

	case pointsUpdated(MatchTeams)
}
