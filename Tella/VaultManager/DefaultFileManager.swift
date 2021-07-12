//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

protocol FileManagerInterface {
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func contents(atPath path: URL) -> Data?
    func contentsOfDirectory(atPath path: URL) -> [URL]

    @discardableResult
    func createFile(atPath path: URL, contents data: Data?) -> Bool
    func removeItem(at path: URL)
}

class DefaultFileManager: FileManagerInterface {
    let fileManager = FileManager.default
    
    func contents(atPath path: URL) -> Data? {
        do {
            return try Data(contentsOf: path)
        } catch let error {
            debugLog(error)
        }
        return nil
    }
    
    func contentsOfDirectory(atPath path: URL) -> [URL] {
        do {
            return try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        } catch let error {
            debugLog(error)
        }
        return []
    }
    
    func removeItem(at path: URL) {
        debugLog("removing \(path.path)")
        do {
            try fileManager.removeItem(at: path)
        } catch let error {
            debugLog(error)
        }
    }
 
    func createFile(atPath path: URL, contents data: Data?) -> Bool {
        debugLog("creating \(path.path)")
        do {
            try data?.write(to: path)
        } catch let error {
            debugLog(error)
            return false
        }
        return true
    }
    
    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        debugLog("copying from \(srcURL.path) \(dstURL.path)")
        try fileManager.copyItem(at: srcURL, to: dstURL)
    }
    
}
