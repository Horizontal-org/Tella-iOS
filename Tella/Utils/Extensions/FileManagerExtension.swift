//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension FileManager {

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
    
    class func tempDirectory(withFileName fileName: String) -> URL {
        return self.default
            .temporaryDirectory
            .appendingPathComponent(fileName)
    }
    
    /// Available free disk space in bytes
    var availableDiskSpace: Int64 {
        do {
            let attrs = try attributesOfFileSystem(forPath: NSHomeDirectory())
            return (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        } catch {
            return 0
        }
    }

}

