//
//  OWLStandingsResponse.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct OWLStandingsResponse: Decodable {
  let data: [OWLStandingsTeam]
}

struct OWLStandingsTeam: Decodable {
  let id: Int
  let name: String
  let preseason: OWLStandings
  let league: OWLStandings
  let stages: OWLStandingsStages
}

struct OWLStandingsStages: Decodable {
  let stage1: OWLStandings
  let stage2: OWLStandings
  let stage3: OWLStandings
  let stage4: OWLStandings
}

struct OWLStandings: Decodable {
  let matchWin: Int
  let matchLoss: Int
  let matchDraw: Int
  let matchBye: Int
  let gameWin: Int
  let gameLoss: Int
  let gameTie: Int
  let comparisons: [OWLStandingsComparison]
  let placement: Int
}

struct OWLStandingsComparison: Decodable {
  let key: String
  let value: Int?
}

extension OWLStandings {
  var matchGameDifferentialString: String {
    let diff = comparisons.first { $0.key == "MATCH_GAME_DIFFERENTIAL" }?.value ?? 0
    return diff >= 0 ? "+\(diff)" : "\(diff)"
  }
}
