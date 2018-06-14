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
    let points: [Int]?
}

struct OWLStubResponse: Decodable { }

func loadJSON<T: Decodable>(named fileName: String) -> T {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
        fatalError("Unable to load resource")
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
        fatalError("Unable to load data")
    }
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(T.self, from: data)
        print("\(response)")
        return response
    } catch {
        fatalError("\(error)")
    }
}

let liveMatch: OWLResponse = loadJSON(named: "live-match")
let stubMatch: OWLStubResponse = loadJSON(named: "live-match-stub")
