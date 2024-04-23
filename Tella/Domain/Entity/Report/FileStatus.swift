//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum FileStatus: Int, Codable {
    case unknown = 0
    case notSubmitted = 1
    case submitted = 2
    case partialSubmitted = 3
    case submissionError = 4
    case uploaded = 5

}
