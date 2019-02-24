//
//  MatchEvent+Message.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

extension MatchEvent {
  var messageBlocks: [MessageBlock] {
    switch self {
    case .matchStartingSoon(let teams):
      let text = "*\(teams.team1.name)* will face off against *\(teams.team2.name)* in _10 minutes_.\n<https://overwatchleague.com|*Watch Live*>"
      return [.text(text)]
    case .matchStarted(let teams):
      let text = "The match is starting between *\(teams.team1.name)* and *\(teams.team2.name)*.\n<https://overwatchleague.com|*Watch Live*>"
      return [.text(text)]
    case .gameStarted(_):
      return [.text("A new game is starting")]
    case .matchEnded(_):
      return [.text("The match has ended")]
    case .gameEnded(_):
      return [.text("The game has ended")]
    }
  }
}
