import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // Basic "Hello, world!" example
  router.get("hello") { req in
    return "Hello, world!"
  }

  router.get(PathComponent.catchall) { req -> Response in
    print("cannot handle request: \(req.description)")
    throw Abort(.notFound)
  }
}
