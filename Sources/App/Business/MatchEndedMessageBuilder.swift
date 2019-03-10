//
//  MatchEndedMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/9/19.
//

import Foundation

struct MatchEndedMessageBuilder {
  private init() {}

  static func buildMessage(with outcome: MatchOutcome) -> [MessageBlock] {
    let title = "*\(outcome.match.winnerName)* has defeated *\(outcome.match.loserName)* \(outcome.match.winner.score)-\(outcome.match.loser.score)"
    var fields = outcome.maps
      .flatMap { outcome -> [String] in
        return [
          "\(outcome.map.type.humanString): \(outcome.map.englishName)",
          "\(outcome.scoreString) \(outcome.winnerNameOrDraw)"
        ]
    }
    fields.insert(contentsOf: ["*Map*", "*Score*"], at: 0)

    return [
      MessageBlock.textSection(title),
      .divider,
      .section(SectionInfo(fields: fields))
    ]
  }
}
