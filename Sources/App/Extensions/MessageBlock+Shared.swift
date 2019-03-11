//
//  MessageBlock+Shared.swift
//  App
//
//  Created by Dalton Claybrook on 3/10/19.
//

import Foundation

extension MessageBlock {
  static func textSection(_ text: String) -> MessageBlock {
    return .section(SectionInfo(text: text))
  }

  static var watchLiveSection: MessageBlock {
    let ctaString = "Watch the action at overwatchleague.com."
    let button = Button(text: "Watch Live", actionId: "watch_live", urlString: "https://overwatchleague.com")
    return .section(SectionInfo(text: ctaString, accessory: button))
  }
}
