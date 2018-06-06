//
//  LiveMatchFetcher.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import Foundation
import Jobs

enum FetchError: Error {
    case unknown
    case decodeError
}

struct LiveMatchFetcher {
    private static let matchURLString = URL(string: "https://api.overwatchleague.com/live-match?expand=team.content&locale=en-us")!

    // MARK: Public

    static func registerAndStartFetching() {
        Jobs.add(interval: .seconds(30), action: fetchLiveMatch)
        fetchLiveMatch()
    }

    // MARK: Private

    private static func fetchLiveMatch() {
        URLSession.shared.dataTask(with: matchURLString) { data, response, error in
            if error == nil,
                let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode),
                let data = data {
                self.handleResponseData(data)
            } else {
                self.handleError(error ?? FetchError.unknown)
            }
        }.resume()
    }

    private static func handleResponseData(_ data: Data) {
        let decoder = JSONDecoder()
        if let matchData = try? decoder.decode(OWLResponse.self, from: data) {
            
        } else if let _ = try? decoder.decode(OWLStubResponse.self, from: data) {
            print("no live match to report")
        } else {
            handleError(FetchError.decodeError)
        }
    }

    private static func handleError(_ error: Error) {

    }
}
