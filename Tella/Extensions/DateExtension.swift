//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum DateFormat : String {
    case short = "DD MMM YYYY"
    case fileInfo = "dd-MM-yyyy HH:mm:ss Z"
}

extension Date{
    
    func getFormattedDateString(format: String = DateFormat.short.rawValue , locale: Locale = Language.english.localeLanguage) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
}

