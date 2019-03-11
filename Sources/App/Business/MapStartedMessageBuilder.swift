//
//  MapStartedMessageBuilder.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

struct MapStartedMessageBuilder {
  private init() {}

  static func buildMessage(with teams: Teams, mapIndex: Int, map: OWLMap) -> [MessageBlock] {
    let title = "Map \(mapIndex + 1) of *\(teams.team1.name)* vs *\(teams.team2.name)* is starting."
    var blocks: [MessageBlock] = [.textSection(title)]

    if let imageURL = map.thumbnailURL {
      blocks.append(.divider)
      let imageInfo = ImageInfo(imageURL: imageURL, altText: map.englishName, title: nil)
      let mapText = "Map: *\(map.englishName.capitalized)*\nType: *\(map.type.rawValue.capitalized)*"

      let sectionInfo = SectionInfo(
        text: mapText,
        accessory: imageInfo
      )
      blocks.append(.section(sectionInfo))
    }

    blocks.append(.watchLiveSection)
    return blocks
  }
}
