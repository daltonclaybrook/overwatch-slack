//: Playground - noun: a place where people can play

import UIKit

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


guard let data = Bundle.main.path(forResource: "live-match", ofType: "json")?.data(using: .utf8) else {
    fatalError()
}

let decoder = JSONDecoder()

do {
    let response = try decoder.decode(OWLResponse.self, from: data)
    print("\(response)")
} catch {
    fatalError("\(error)")
}
