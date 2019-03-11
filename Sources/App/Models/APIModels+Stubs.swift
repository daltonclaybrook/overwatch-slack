//
//  APIModels+Stubs.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Foundation

protocol PartialMatchResponseType {
  var liveMatch: OWLLiveMatch? { get }
  var nextMatch: OWLLiveMatch? { get }
}

struct OWLHalfStubResponse: Decodable {
  let data: OWLHalfStubData
}

struct OWLFullStubResponse: Decodable {
  let data: OWLFullStubData
}

struct OWLHalfStubData: Decodable {
  let liveMatch: OWLLiveMatch
  let nextMatch: OWLStubMatch
}

struct OWLFullStubData: Decodable {
  let liveMatch: OWLStubMatch
  let nextMatch: OWLStubMatch
}

// empty
struct OWLStubMatch: Decodable {}

extension OWLLiveMatchResponse: PartialMatchResponseType {
  var liveMatch: OWLLiveMatch? {
    return data.liveMatch
  }
  var nextMatch: OWLLiveMatch? {
    return data.nextMatch
  }
}

extension OWLHalfStubResponse: PartialMatchResponseType {
  var liveMatch: OWLLiveMatch? {
    return data.liveMatch
  }
  var nextMatch: OWLLiveMatch? {
    return nil
  }
}

extension OWLFullStubResponse: PartialMatchResponseType {
  var liveMatch: OWLLiveMatch? {
    return nil
  }
  var nextMatch: OWLLiveMatch? {
    return nil
  }
}
