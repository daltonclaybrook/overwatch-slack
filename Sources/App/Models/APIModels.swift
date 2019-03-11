//
//  APIModels.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import Foundation

struct OWLLiveMatchResponse: Decodable {
  let data: OWLLiveMatchResponseData
}

struct OWLLiveMatchResponseData: Decodable {
  let liveMatch: OWLLiveMatch
  let nextMatch: OWLLiveMatch
}

struct OWLLiveMatch: Decodable {
  let id: Int
  let conclusionStrategy: String
  let dateCreated: Int // milliseconds
  let startDateTS: Int // milliseconds
  let actualStartDate: Int? // milliseconds
  let endDateTS: Int // milliseconds
  let showStartTime: Bool
  let status: OWLGameMatchStatus
  let statusReason: String
  let wins: [Int]
  let competitors: [OWLCompetitor]
  let scores: [OWLScore]
  let games: [OWLGame]
  let winner: OWLCompetitor?
}

extension OWLLiveMatch {
  var startDate: Date {
    return Date(timeIntervalSince1970: TimeInterval(startDateTS / 1000))
  }

  var realStartDate: Date? {
    return actualStartDate.map { Date(timeIntervalSince1970: TimeInterval($0 / 1000)) }
  }
}

struct OWLCompetitor: Decodable, Equatable {
  let id: Int
  let name: String
  let homeLocation: String
  let primaryColor: String // hex string
  let secondaryColor: String // hex string
  let abbreviatedName: String
  let logo: URL
  let icon: URL
  let secondaryPhoto: URL
  let addressCountry: String
}

struct OWLScore: Decodable, Equatable {
  let value: Int
}

struct OWLGame: Decodable {
  let id: Int
  let number: Int
  let points: [Int]?
  let status: OWLGameMatchStatus
  let statusReason: String
  let attributes: OWLGameAttributes
}

enum OWLGameMatchStatus: String, Decodable {
  case pending = "PENDING"
  case inProgress = "IN_PROGRESS"
  case concluded = "CONCLUDED"
}

struct OWLGameAttributes: Decodable {
  let mapScore: OWLMapScore?
  let map: String?
  let mapGuid: String
}

struct OWLMapScore: Decodable {
  let team1: Int
  let team2: Int
}
