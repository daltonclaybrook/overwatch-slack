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
	case text(String)
  case section(SectionInfo)
  case divider
  case image(ImageInfo)
	case context([MessageBlock])
}

extension MessageBlock {
	static func textSection(_ text: String) -> MessageBlock {
		return .section(SectionInfo(text: text))
	}
}
