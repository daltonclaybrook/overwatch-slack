import Jobs
import Vapor

var liveMatchFetcher: LiveMatchFetcher?

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    liveMatchFetcher = try LiveMatchFetcher(container: app)
    liveMatchFetcher?.registerAndStartFetching()
}
