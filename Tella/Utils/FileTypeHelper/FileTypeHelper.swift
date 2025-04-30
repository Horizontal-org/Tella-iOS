//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public struct FileTypeHelper {
    
    /// File data
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    /// A  method to get the `MimeType` that matches the given file data
    ///
    /// - Returns: Optional<FileInformation>
    public func getFileInformation() -> FileInformation? {
        let bytes = self.getBytes()
        
        for mime in FileInformation.all {
            if mime.matches(bytes: bytes) {
                return mime
            }
        }
        return nil
    }
    
    /// Get bytes from data
    ///
    /// - returns: Bytes represented with `[UInt8]`
    internal func getBytes() -> [UInt8] {
        let count = min(data.count, 262)
        var bytes = [UInt8](repeating: 0, count: count)
        data.copyBytes(to: &bytes, count: count)
        return bytes
    }
}
