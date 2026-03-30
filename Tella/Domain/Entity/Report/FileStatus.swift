//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
