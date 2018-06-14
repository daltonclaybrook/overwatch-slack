//
//  LiveMatchFetcher.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import Foundation
import Jobs
import Vapor

enum FetchError: Error {
    case unknown
    case decodeError
}

class LiveMatchFetcher {
    private let matchURLString = URL(string: "https://api.overwatchleague.com/live-match?expand=team.content&locale=en-us")!
    private var client: Client?

    // MARK: Public

    func registerAndStartFetching(_ application: Application) throws {
        self.client = try application.client()
        
        Jobs.add(interval: .seconds(30), action: fetchLiveMatch)
        fetchLiveMatch()
    }

    // MARK: Private

    private func fetchLiveMatch() {
        do {
            print("Fetching matches...")
            
            client?.get(matchURLString).whenSuccess { response in
                do {
                    print("Decoding \(OWLResponse.self)...")
                    try response.content.decode(OWLResponse.self).whenSuccess { owlResponse in
                        print("Fetched response data: \(owlResponse)")
                    }
                } catch {
                    do {
                        let matchDataStub = try response.content.decode(OWLStubResponse.self)
                        print("Fetched stub: \(matchDataStub)")
                    } catch {
                        print("Failed: \(error)")
                    }
                }
            }
        }
    }
}
