//
//  MatchEvent+Message.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

extension MatchEvent {
  var message: Message {
    switch self {
    case .matchStartingSoon(let teams):
			return MatchStartingSoonMessageBuilder.buildMessage(with: teams)
    case .matchStarted(let info):
      return MatchStartedMessageBuilder.buildMessage(with: info)
    case .mapStarted(let teams, let mapIndex, let map):
			return MapStartedMessageBuilder.buildMessage(with: teams, mapIndex: mapIndex, map: map)
    case .matchEnded(let outcome):
			return MatchEndedMessageBuilder.buildMessage(with: outcome)
    case .mapEnded(let outcome, let mapIndex):
			return MapEndedMessageBuilder.buildMessage(with: outcome, mapIndex: mapIndex)
		case .pointsUpdated(let teams):
      // todo
      return Message(text: "points updated", blocks: [.text("points updated")])
    }
  }
}
