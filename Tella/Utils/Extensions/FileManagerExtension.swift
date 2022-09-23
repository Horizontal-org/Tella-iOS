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
    
    class func documentDirectory(withPath path: String) -> URL? {
        do {
            return try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(path)
        }
        catch {
            return nil
        }
    }
    
}
