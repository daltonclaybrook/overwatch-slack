//
//  MapEndedMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct MapEndedMessageBuilder {
  private init() {}

  static func buildMessage(with outcome: MapOutcome, mapIndex: Int) -> [MessageBlock] {
    var blocks: [MessageBlock] = []
    switch outcome {
    case .win(_, let outcome):
      let text = "*\(outcome.winner.team.name)* has won the map against *\(outcome.loser.team.name)*!"
      blocks.append(.textSection(text))
      blocks.append(.divider)
      let fields = [
        "\(outcome.winner.team.name): *\(outcome.winner.score)*",
        "\(outcome.loser.team.name): *\(outcome.loser.score)*"
      ]
      let info = SectionInfo(text: "Score:", fields: fields)
      blocks.append(.section(info))
    case .draw(_, let teams, let score):
      let text = "It's a draw! Map \(mapIndex + 1) between *\(teams.team1.name)* and *\(teams.team2.name)* has ended with a score of \(score)-\(score)"
      blocks.append(.textSection(text))
    }
    blocks.append(.watchLiveSection)
    return blocks
  }
}
