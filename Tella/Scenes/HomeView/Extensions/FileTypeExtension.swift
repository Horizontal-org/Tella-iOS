//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

func ~=<T : Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}
