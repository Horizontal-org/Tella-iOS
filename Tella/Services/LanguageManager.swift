//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum Language: String {
    
    case english = "en"
    case arabic = "ar"

    var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en")
        case .arabic:
            return Locale(identifier: "ar")
        }
    }

}
