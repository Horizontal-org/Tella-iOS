//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

func ~=<T : Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}
