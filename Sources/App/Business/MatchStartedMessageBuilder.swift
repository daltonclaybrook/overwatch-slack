//
//  MatchStartedMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct MatchStartedMessageBuilder {
  private static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "PST")
    formatter.dateFormat = "HH:mm"
    return formatter
  }()

  private init() {}

  static func buildMessage(with info: MatchStartInfo) -> [MessageBlock] {
    let title = "*\(info.teams.team1.name)* vs *\(info.teams.team2.name)* has started."

    let fallbackDateString = formatter.string(from: info.startDate)
    let timestamp = Int(info.startDate.timeIntervalSince1970)
    let dateText = "<!date^\(timestamp)^Match Start: {time}|Match Start: \(fallbackDateString) PST>"

    let team1League = info.standings.team1.league
    let team2League = info.standings.team2.league
    let fields: [String] = [
      "*\(info.teams.team1.name)*",
      "*\(info.teams.team2.name)*",
      "WL (\(team1League.matchWin)-\(team1League.matchLoss))",
      "WL (\(team2League.matchWin)-\(team2League.matchLoss))",
      "DIFF \(team1League.matchGameDifferentialString)",
      "DIFF \(team2League.matchGameDifferentialString)"
    ]

    let ctaString = "Watch the action at overwatchleague.com."
    let button = Button(text: "Watch Live", actionId: "watch_live", urlString: "https://overwatchleague.com")

    return [
      .textSection(title),
      .context([.text(dateText)]),
      .divider,
      .section(SectionInfo(fields: fields)),
      .section(SectionInfo(text: ctaString, accessory: button))
    ]
  }
}
