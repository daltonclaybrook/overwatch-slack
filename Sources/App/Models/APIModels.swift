//
//  APIModels.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import Foundation

struct OWLResponse: Decodable {
    let data: OWLResponseData
}

struct OWLResponseData: Decodable {
    let liveMatch: OWLResponseMatch
    let nextMatch: OWLResponseMatch
}

struct OWLResponseMatch: Decodable {
    let id: Int
    let competitors: [OWLResponseCompetitor]
    let scores: [OWLResponseScore]
    let games: [OWLResponseGame]
}

struct OWLResponseCompetitor: Decodable {
    let id: Int
    let name: String
    let homeLocation: String
    let primaryColor: String // hex string
    let secondaryColor: String // hex string
    let abbreviatedName: String
    let logo: URL
    let icon: URL
    let secondaryPhoto: URL
}

struct OWLResponseScore: Decodable {
    let value: Int
}

struct OWLResponseGame: Decodable {
    let id: Int
    let number: Int
    let points: [Int]
}

struct OWLStubResponse: Decodable {
    let data: OWLStubResponseData
}

struct OWLStubResponseData: Decodable {
    let liveMatch: OWLStubResponseMatch
    let nextMatch: OWLStubResponseMatch
}

// empty
struct OWLStubResponseMatch: Decodable {}

