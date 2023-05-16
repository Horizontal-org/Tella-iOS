//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension FileManager {
    
    func sizeOfFile(atPath path: String) -> Int? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            return attr[FileAttributeKey.size] as? Int
        } catch {
            return nil
        }
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
