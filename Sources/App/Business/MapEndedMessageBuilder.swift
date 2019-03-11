//
//  MapEndedMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct MapEndedMessageBuilder {
  private init() {}

  static func buildMessage(with outcome: MapOutcome, mapIndex: Int) -> Message {
    var blocks: [MessageBlock] = []
    let title: String
    switch outcome {
    case .win(_, let outcome):
      title = "*\(outcome.winner.team.name)* has won the map against *\(outcome.loser.team.name)*!"
      blocks.append(.textSection(title))
      blocks.append(.divider)
      let fields = [
        "\(outcome.winner.team.name): *\(outcome.winner.score)*",
        "\(outcome.loser.team.name): *\(outcome.loser.score)*"
      ]
      let info = SectionInfo(text: "Score:", fields: fields)
      blocks.append(.section(info))
    case .draw(_, let teams, let score):
      title = "It's a draw! Map \(mapIndex + 1) between *\(teams.team1.name)* and *\(teams.team2.name)* has ended with a score of \(score)-\(score)"
      blocks.append(.textSection(title))
    }
    blocks.append(.watchLiveSection)
    return Message(text: title, blocks: blocks)
  }
}
