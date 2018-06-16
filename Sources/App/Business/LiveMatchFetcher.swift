//
//  LiveMatchFetcher.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import Foundation
import Jobs
import Vapor

enum MatchEvent {
    case matchStarted
    case teamScored
    case matchEnded
}

class LiveMatchFetcher {
    
    // MARK: - Properties
    
    private let matchURLString = URL(string: "https://api.overwatchleague.com/live-match?expand=team.content&locale=en-us")!
    private let container: Container
    private let logger: Logger
    private let client: Client
    private var currentMatchData: OWLResponse? // TODO: Remove when fetching from database
    
    // MARK: - Init
    
    init(container: Container) throws {
        self.container = container
        
        self.logger = try container.make(Logger.self)
        self.client = try container.client()
    }

    // MARK: Public
    
    func registerAndStartFetching() {
        Jobs.add(interval: .seconds(30), action: fetchLiveMatch)
        fetchLiveMatch()
    }

    // MARK: Private

    private func fetchLiveMatch() {
        logger.info("Fetching matches")
        
        let matchFetchResult = fetchLatestMatchData()
        matchFetchResult.whenSuccess { fetchedOWLResponse in
            self.logger.info("Fetched match data: \(fetchedOWLResponse)")
            
            self.logger.info("Fetching current match data from database")
            let currentMatchDataFetch = self.fetchSavedMatchData()
            currentMatchDataFetch.whenSuccess { savedOWLResponse in
                
                // TODO: Datect what's changed between the old match data ('savedOWLResponse') and the current match data ('fetchedOWLResponse')
                
            }
            currentMatchDataFetch.whenFailure { error in
                self.logger.info("Failed to fetch current match from database: \(error)")
            }
        }
        matchFetchResult.whenFailure { error in
            self.logger.info("Error fetching match data: \(error)")
        }
    }
    
    private func detectMatchEvent(fromPreviousMatchData previousMatchData: OWLResponse?, currentMatchData: OWLResponse) -> MatchEvent {
        switch (previousMatchData, currentMatchData) {
        case (.none, let currentMatchData):
            return .matchStarted
        case (.some(let previousMatchData), let currentMatchData):
            let previousWins = previousMatchData.data.liveMatch.wins
            let currentWins = currentMatchData.data.liveMatch.wins
            
            // TODO: Best way to parse who scored?
            
            return .teamScored
        }
        
        return .matchStarted
    }
    
    private func fetchSavedMatchData() -> Future<OWLResponse?> {
        // TODO: Fetch out of the database
        return container.eventLoop.newSucceededFuture(result: currentMatchData)
    }
    
    private func fetchLatestMatchData() -> Future<OWLResponse> {
        return client.get(matchURLString).flatMap { response in
            return try response.content.decode(OWLResponse.self)
        }
    }
}
