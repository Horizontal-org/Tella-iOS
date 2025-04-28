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

}
