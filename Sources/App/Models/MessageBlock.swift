//
//  MessageBlock.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

struct SectionInfo {
  let text: String
  let fields: [String]
  let accessory: ImageInfo?

  init(text: String, fields: [String] = [], accessory: ImageInfo? = nil) {
    self.text = text
    self.fields = fields
    self.accessory = accessory
  }
}

struct ImageInfo {
  let imageURL: URL
  let altText: String
  let title: String?
}

enum MessageBlock {
  case section(SectionInfo)
  case divider
  case image(ImageInfo)
}

extension MessageBlock {
  static func text(_ text: String) -> MessageBlock {
    return .section(SectionInfo(text: text))
  }
}
