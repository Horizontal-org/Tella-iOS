//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension Double {
    
    func timeString() -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits =  self > 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
       
        let string = formatter.string(from: self) ?? ""
        return string.hasPrefix("0") && string.count > 4 ? .init(string.dropFirst()) : string
    }
}
