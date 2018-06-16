//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func downloadLiveMatchData() {
    let task = URLSession.shared.dataTask(with: URL(string: "https://api.overwatchleague.com/live-match?expand=team.content&locale=en-us")!) { (data, response, error) in
        guard let data = data else {
            debugPrint("Failed to download data: \(String(describing: error))")
            return
        }
        
        do {
            let rawJSONObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            let formattedJSONData = try JSONSerialization.data(withJSONObject: rawJSONObject, options: [.prettyPrinted])

            let fileURLPath = "live-match_\(Date()).json"
            let fileURL = playgroundSharedDataDirectory.appendingPathComponent(fileURLPath)
            
            try formattedJSONData.write(to: fileURL, options: .atomic)
            
            debugPrint("\(rawJSONObject)")
        } catch {
            debugPrint("Error handling data: \(error)")
        }
    }
    task.resume()
}

// Kick off an inital fetch
downloadLiveMatchData()

let secondsPerMinute = 60
let downloadInterval = secondsPerMinute * 10 // 10 min

_ = Timer.scheduledTimer(withTimeInterval: TimeInterval(downloadInterval), repeats: true, block: { (_) in
    downloadLiveMatchData()
})

