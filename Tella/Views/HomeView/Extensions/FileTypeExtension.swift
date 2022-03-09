//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

func ~=<T : Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}

extension Array where Element == FileType {

    func getTitle() -> String {
        switch self {
        case [.audio]:
            return "Audio"
 
        case [.image, .video]:
            return "Images and Videos"

        default:
            return ""
        }
    }
}
