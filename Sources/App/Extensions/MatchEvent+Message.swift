//
//  MatchEvent+Message.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

extension MatchEvent {
  var messageText: String {
    switch self {
    case .matchStartingSoon(let teams):
      return "*\(teams.team1.name)* will face off against *\(teams.team2.name)* in _10 minutes_.\n<https://overwatchleague.com|*Watch Live*>"
    case .matchStarted(let teams):
      return "The match is starting between *\(teams.team1)* and *\(teams.team2)*.\n<https://overwatchleague.com|*Watch Live*>"
    case .gameStarted(_):
      return "A new game is starting"
    case .matchEnded(_):
      return "The match has ended"
    case .gameEnded(_):
      return "The game has ended"
    }
  }
}

extension MatchEvent {
  var messageBlocks: [MessageBlock] {
    return []
  }
}
