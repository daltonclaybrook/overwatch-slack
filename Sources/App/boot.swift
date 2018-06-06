import Jobs
import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    LiveMatchFetcher.registerAndStartFetching()
}

