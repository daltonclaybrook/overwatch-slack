//
//  OWLMap.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

enum MapType: String, Decodable {
  case assault
  case hybrid
  case escort
  case control
  case arena
  case deathmatch
  case lucioball
  case none = ""
}

struct OWLMap: Decodable {
  let id: String
  let guid: String
  let name: [String: String]
  let icon: URL
  let thumbnail: URL
  let type: MapType
}

extension OWLMap {
  var englishName: String {
    // should always be non-nil
    return name["en_US"] ?? ""
  }
}
