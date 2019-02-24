//
//  EventPublisher.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Vapor

final class EventPublisher {
  private let app: Application

  init(app: Application) {
    self.app = app
  }

  func publish(event: MatchEvent) {
    
  }
}
