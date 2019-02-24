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

enum GameOutcome {
  case win(OWLResponseCompetitor)
  case draw
}

enum MatchEvent {
  // ten minutes
  case matchStartingSoon(MatchTeams)
  // only one of these events will fire at a time,
  // whichever is most significant
  case matchStarted(MatchTeams)
  case gameStarted(MatchTeams)

  // only one of these events will fire at a time,
  // whichever is most significant
  case matchEnded(MatchTeams)
  case gameEnded(MatchTeams)
}
