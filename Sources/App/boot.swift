import Jobs
import Vapor

let liveMatchFetcher = LiveMatchFetcher()

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    try liveMatchFetcher.registerAndStartFetching(app)
}

