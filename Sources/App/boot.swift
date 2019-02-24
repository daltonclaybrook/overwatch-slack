import Vapor

var fetcher: MatchFetcher?

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
  fetcher = MatchFetcher(container: app)
  try fetcher?.startFetching()
}
