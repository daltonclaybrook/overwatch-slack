//
//  MessageBlock+Payload.swift
//  App
//
//  Created by Dalton Claybrook on 2/24/19.
//

import Foundation

extension MessageBlock {
  var payload: [String: Any] {
    switch self {
    case .section(let info):
      return info.payload
    case .divider:
      return [ "type": "divider" ]
    case .image(let info):
      return info.payload
    }
  }

  private var payloadType: String {
    switch self {
    case .section: return "section"
    case .divider: return "divider"
    case .image: return "image"
    }
  }
}

extension SectionInfo {
  var payload: [String: Any] {
    var payload: [String: Any] = [
      "type": "section",
      "text": [
        "type": "mrkdwn",
        "text": text
      ]
    ]
    if !fields.isEmpty {
      payload["fields"] = fields.map {
        [
          "type": "mrkdwn",
          "text": $0
        ]
      }
    }
    if let accessory = accessory {
      payload["accessory"] = accessory.payload
    }
    return payload
  }
}

extension ImageInfo {
  var payload: [String: Any] {
    var payload: [String: Any] = [
      "type": "image",
      "image_url": imageURL.absoluteString,
      "alt_text": altText
    ]
    if let title = title {
      payload["title"] = [
        "type": "plain_text",
        "text": title
      ]
    }
    return payload
  }
}

extension Sequence where Element == MessageBlock {
  func messagePayloadData() throws -> Data {
    let payload = map { $0.payload }
    return try JSONSerialization.data(withJSONObject: payload, options: [])
  }
}
