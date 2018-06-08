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
            
            _ = client?.get(matchURLString).then({ (response) -> Future<String> in
                do {
                    print("Decoding \(OWLResponse.self)...")
                    return try response.content.decode(OWLResponse.self).flatMap { owlResponse in
                        
                        print("Fetched response data: \(owlResponse)")
                        return response.eventLoop.newSucceededFuture(result: "SUCCESS")
                    }
                } catch {
                    do {
                        let matchDataStub = try response.content.decode(OWLStubResponse.self)
                        print("Fetched stub: \(matchDataStub)")
                        
                        return response.eventLoop.newSucceededFuture(result: "STUB")
                    } catch {
                        print("Failed: \(error)")
                        return response.eventLoop.newFailedFuture(error: error)
                    }
                }
            })
        }
    }
}
