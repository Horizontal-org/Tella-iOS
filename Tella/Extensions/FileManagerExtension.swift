//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension FileManager {
   
    func sizeOfFile(atPath path: String) -> Int64? {
        guard let attrs = try? attributesOfItem(atPath: path) else {
            return nil
        }
        return attrs[.size] as? Int64
    }
}
