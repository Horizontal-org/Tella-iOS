//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation


typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}

