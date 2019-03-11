//
//  MessageBlock.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

protocol SectionAccessory {
  var payload: [String: Any] { get }
}

struct SectionInfo {
  let text: String?
  let fields: [String]
  let accessory: SectionAccessory?

  init(text: String? = nil, fields: [String] = [], accessory: SectionAccessory? = nil) {
    self.text = text
    self.fields = fields
    self.accessory = accessory
  }
}

struct ImageInfo: SectionAccessory {
  let imageURL: URL
  let altText: String
  let title: String?
}

struct Button: SectionAccessory {
  let text: String
  let actionId: String
  let urlString: String?
}

enum MessageBlock {
	case text(String)
  case section(SectionInfo)
  case divider
  case image(ImageInfo)
	case context([MessageBlock])
}

struct Message {
  let text: String
  let blocks: [MessageBlock]
}
