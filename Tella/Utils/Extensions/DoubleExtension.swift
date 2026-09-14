//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension Double {
    
    var timeFormatter : DateComponentsFormatter {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits =  self > 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    func shortTimeString() -> String {
        let string = timeFormatter.string(from: self) ?? ""
        return string.hasPrefix("0") && string.count > 4 ? .init(string.dropFirst()) : string
    }
    
    func timeString() -> String {
        return timeFormatter.string(from: self) ?? ""
    }
    
    func getDate() -> Date? {
      return  Date(timeIntervalSince1970: TimeInterval(self))
    }

    var displayedLatitude: String {
        dmsString(positiveDirection: "N", negativeDirection: "S")
    }
    
    var displayedLongitude: String {
        dmsString(positiveDirection: "E", negativeDirection: "W")
    }
    
    private func dmsString(positiveDirection: String, negativeDirection: String) -> String {
        let direction = self >= 0 ? positiveDirection : negativeDirection
        let totalSeconds = (abs(self) * 3600 * 100_000).rounded() / 100_000
        
        var degrees = Int(totalSeconds / 3600)
        let remainingSeconds = totalSeconds - Double(degrees) * 3600
        var minutes = Int(remainingSeconds / 60)
        var seconds = remainingSeconds - Double(minutes) * 60
        
        if seconds >= 60 {
            seconds = 0
            minutes += 1
        }
        if minutes >= 60 {
            minutes = 0
            degrees += 1
        }
        
        let secondsString = String(format: "%.5f", locale: Locale(identifier: "en_US_POSIX"), seconds)
        return "\(degrees)° \(minutes)' \(secondsString)\" \(direction)"
    }

}
