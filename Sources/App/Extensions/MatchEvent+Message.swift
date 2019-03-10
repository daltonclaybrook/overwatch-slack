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
    case .matchStarted(let info):
      return MatchStartedMessageBuilder.buildMessage(with: info)
    case .mapStarted(let teams, let mapIndex, let map):
			// Example:
			// "Map 3 of Houston Outlaws vs Dallas Fuel is starting."
			// <divider>
			// "Map: Kings Row"
			// "Type: Hybrid"
			// <map image accesory>

			var blocks: [MessageBlock] = []
			blocks.append(.textSection(
				"Map \(mapIndex + 1) of *\(teams.team1.name)* vs *\(teams.team2.name)* is starting.\n<https://overwatchleague.com|*Watch Live*>"
			))
			if let imageURL = map.thumbnailURL {
				blocks.append(.divider)
				let imageInfo = ImageInfo(imageURL: imageURL, altText: map.englishName, title: nil)
				let sectionInfo = SectionInfo(
					text: "Map: *\(map.englishName.capitalized)*\nType: *\(map.type.rawValue.capitalized)*",
					accessory: imageInfo
				)
				blocks.append(.section(sectionInfo))
			}
			blocks.append(MatchEvent.context)
      return blocks
    case .matchEnded(let outcome):
			return MatchEndedMessageBuilder.buildMessage(with: outcome)
    case .mapEnded(let outcome, let mapIndex):
			// Example:
			// "Houston Outlaws have won map 3 against Dallas Fuel!"
			// <divider>
			// "Maps won:"
			// "Houston Outlaws: 2		Dallas Fuel: 1"
      return blocksForMapEnded(outcome, mapIndex: mapIndex)
		case .pointsUpdated(let teams):
			// Example:
			// "The score has been updated for map 3 of Houston Outlaws vs Dallas Fuel"
			// "Score:"
			// "Houston Outlaws: 3		Dallas Fuel: 2"
			return [.text("points updated")]
    }
  }

	// MARK: - Private

	private func blocksForMapEnded(_ outcome: MapOutcome, mapIndex: Int) -> [MessageBlock] {
		var blocks: [MessageBlock] = []
		switch outcome {
		case .win(let map, let outcome):
			blocks.append(.textSection("*\(outcome.winner.team.name)* have won the map against *\(outcome.loser.team.name)*!"))
			blocks.append(.divider)
			let fields = [
				"\(outcome.winner.team.name): *\(outcome.winner.score)*",
				"\(outcome.loser.team.name): *\(outcome.loser.score)*"
			]
			let info = SectionInfo(text: "Score:", fields: fields)
			blocks.append(.section(info))
    case .draw(let map, let teams, let score):
			blocks.append(.textSection("It's a draw! Map \(mapIndex + 1) between *\(teams.team1.name)* and *\(teams.team2.name)* has ended with a score of \(score)-\(score)"))
		}
		blocks.append(MatchEvent.context)
		return blocks
	}
}

extension MatchEvent {
	private static let context: MessageBlock = {
		let contextIconURL = URL(string: "https://styleguide.overwatchleague.com/6.6.2/assets/toolkit/images/logo-tracer.png")!
		let info = ImageInfo(
			imageURL: contextIconURL,
			altText: "logo",
			title: nil
		)
		let blocks: [MessageBlock] = [
			.image(info),
			.text("OWL Slack")
		]
		return .context(blocks)
	}()
}
