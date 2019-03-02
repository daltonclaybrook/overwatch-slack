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

			var blocks: [MessageBlock] = []
			blocks.append(.textSection(
				"Game \(gameIndex + 1) of *\(teams.team1.name)* vs *\(teams.team2.name)* is starting.\n<https://overwatchleague.com|*Watch Live*>"
			))
			if let map = map, let imageURL = map.thumbnailURL {
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
			// Example:
			// "Houston Outlaws have won the match againse Dallas Fuel!"
			// <divider>
			// "Games won:"
			// "Houston Outlaws: 3		Dallas Fuel: 1"
			var blocks: [MessageBlock] = []
			blocks.append(.textSection("*\(outcome.winner.team.name)* have won the match against *\(outcome.loser.team.name)*!"))
			blocks.append(.divider)
			let fields = [
				"\(outcome.winner.team.name): *\(outcome.winner.score)*",
				"\(outcome.loser.team.name): *\(outcome.loser.score)*"
			]
			let info = SectionInfo(text: "Games won:", fields: fields)
			blocks.append(.section(info))

			blocks.append(MatchEvent.context)
      return blocks
    case .gameEnded(let outcome, let gameIndex):
			// Example:
			// "Houston Outlaws have won game 3 against Dallas Fuel!"
			// <divider>
			// "Games won:"
			// "Houston Outlaws: 2		Dallas Fuel: 1"
      return blocksForGameEnded(outcome, gameIndex: gameIndex)
		case .pointsUpdated(let teams):
			// Example:
			// "The score has been updated for game 3 of Houston Outlaws vs Dallas Fuel"
			// "Score:"
			// "Houston Outlaws: 3		Dallas Fuel: 2"
			return [.text("points updated")]
    }
  }

	// MARK: - Private

	private func blocksForGameEnded(_ outcome: Outcome, gameIndex: Int) -> [MessageBlock] {
		var blocks: [MessageBlock] = []
		switch outcome {
		case .win(let outcome):
			blocks.append(.textSection("*\(outcome.winner.team.name)* have won the game against *\(outcome.loser.team.name)*!"))
			blocks.append(.divider)
			let fields = [
				"\(outcome.winner.team.name): *\(outcome.winner.score)*",
				"\(outcome.loser.team.name): *\(outcome.loser.score)*"
			]
			let info = SectionInfo(text: "Score:", fields: fields)
			blocks.append(.section(info))
		case .draw(let teams, let score):
			blocks.append(.textSection("It's a draw! Game \(gameIndex + 1) between *\(teams.team1.name)* and *\(teams.team2.name)* has ended with a score of \(score)-\(score)"))
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
