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
