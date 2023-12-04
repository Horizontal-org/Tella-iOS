//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


extension Dictionary {
    func decode<T: Codable>(_ type: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode (type, from: data)
    }
}

