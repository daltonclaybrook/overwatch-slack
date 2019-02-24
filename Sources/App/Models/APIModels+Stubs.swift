//
//  APIModels+Stubs.swift
//  App
//
//  Created by Dalton Claybrook on 2/23/19.
//

import Foundation

struct OWLStubResponse: Decodable {
  let data: OWLStubResponseData
}

struct OWLStubResponseData: Decodable {
  let liveMatch: OWLStubResponseMatch
}

// empty
struct OWLStubResponseMatch: Decodable {}
