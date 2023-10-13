//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum FeedbackStatus : Int, Codable {
    case unknown = 0
    case draft = 1
    case pending = 2
    case error = 3
}
