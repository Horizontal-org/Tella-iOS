//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    
    class func tempDirectory(withFileName fileName: String) -> URL? {
        return FileManager.default
            .temporaryDirectory
            .appendingPathComponent(fileName)
    }
}

