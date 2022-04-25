//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

func ~=<T : Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}
