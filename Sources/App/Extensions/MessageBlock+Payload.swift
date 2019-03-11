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
		case .text(let text):
			return [
				"type": "mrkdwn",
				"text": text
			]
    case .section(let info):
      return info.payload
    case .divider:
      return [ "type": "divider" ]
    case .image(let info):
      return info.payload
		case .context(let elements):
			let payloads = elements.map { $0.payload }
			return [
				"type": "context",
				"elements": payloads
			]
    }
  }
}

extension SectionInfo {
  var payload: [String: Any] {
    var payload: [String: Any] = [
      "type": "section",
    ]
    if let text = text {
      payload["text"] = [
        "type": "mrkdwn",
        "text": text
      ]
    }
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

extension Button {
  var payload: [String : Any] {
    var payload: [String: Any] = [
      "type": "button",
      "action_id": actionId,
      "text": [
        "type": "plain_text",
        "text": text
      ]
    ]
    if let urlString = urlString {
      payload["url"] = urlString
    }
    return payload
  }
}

extension Message {
  func payloadData() throws -> Data {
    let blockPayloads = blocks.map { $0.payload }
    let data = try JSONSerialization.data(withJSONObject: blockPayloads, options: [])
    let blockDataString = String(data: data, encoding: .utf8) ?? ""
    let blockPayload = [
      "text": text,
      "blocks": blockDataString
    ]
    return try JSONSerialization.data(withJSONObject: blockPayload, options: [])
  }
}
