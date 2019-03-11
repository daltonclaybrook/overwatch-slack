//
//  MatchStartingSoonMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct MatchStartingSoonMessageBuilder {
  private init() {}

  static func buildMessage(with teams: Teams) -> Message {
    let title = "*\(teams.team1.name)* will face off against *\(teams.team2.name)* in _10 minutes_."

    return Message(
      text: title,
      blocks: [
        .textSection(title),
        .watchLiveSection
      ]
    )
  }
}
