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
  case captureTheFlag = "ctf"
  case none = ""
}

struct OWLMap: Decodable {
  let id: String
  let guid: String
  let name: [String: String]
  let icon: String // url
  let thumbnail: String // url
  let type: MapType
}

extension OWLMap {
  var englishName: String {
    // should always be non-nil
    return name["en_US"] ?? ""
  }

  var iconURL: URL? {
    return URL(string: icon)
  }

  var thumbnailURL: URL? {
    return URL(string: thumbnail)
  }
}

extension MapType {
  var humanString: String {
    switch self {
    case .assault:
      return "Assault"
    case .hybrid:
      return "Hybrid"
    case .escort:
      return "Escort"
    case .control:
      return "Control"
    case .arena:
      return "Arena"
    case .deathmatch:
      return "Deathmatch"
    case .lucioball:
      return "Lucioball"
    case .captureTheFlag:
      return "Capture The Flag"
    case .none:
      return "None"
    }
  }
}
