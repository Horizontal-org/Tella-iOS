//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension Sequence {
    func limit(_ max: Int) -> [Element] {
        return self.enumerated()
            .filter { $0.offset < max }
            .map { $0.element }
    }
}
