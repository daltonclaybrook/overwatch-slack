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
			// Example:
			// "Houston Outlaws will face off against Dallas Fuel in 10 minutes. Watch Live."
      let text = "*\(teams.team1.name)* will face off against *\(teams.team2.name)* in _10 minutes_.\n<https://overwatchleague.com|*Watch Live*>"
      return [.text(text)]
    case .matchStarted(let teams):
			// Example:
			// "The match is starting between Houston Outlaws and Dallas Fuel."
			// - maybe list team win/loss records?
      let text = "The match is starting between *\(teams.team1.name)* and *\(teams.team2.name)*.\n<https://overwatchleague.com|*Watch Live*>"
      return [.text(text)]
    case .gameStarted(let teams, let gameIndex, let map):
			// Example:
			// "Game 3 of Houston Outlaws vs Dallas Fuel is starting."
			// <divider>
			// "Map: Kings Row"
			// "Type: Hybrid"
			// <map image accesory>
      return [.text("A new game is starting")]
    case .matchEnded(_):
			// Example:
			// "Houston Outlaws have won the match againse Dallas Fuel!"
			// <divider>
			// "Games won:"
			// "Houston Outlaws: 3		Dallas Fuel: 1"
      return [.text("The match has ended")]
    case .gameEnded(_):
			// Example:
			// "Houston Outlaws have won game 3 against Dallas Fuel!"
			// <divider>
			// "Games won:"
			// "Houston Outlaws: 2		Dallas Fuel: 1"
      return [.text("The game has ended")]
		case .pointsUpdated(let teams):
			// Example:
			// "The score has been updated for game 3 of Houston Outlaws vs Dallas Fuel"
			// "Score:"
			// "Houston Outlaws: 3		Dallas Fuel: 2"
			return [.text("points updated")]
    }
  }
}
