//
//  FileHandleExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/10/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


extension FileHandle {
    
    // FileHandle extension to read chunks
    func readChunk(from offset: Int64, chunkSize: Int64, fileSize: Int64) throws -> Data {
        var data = Data()
        // Check if we need to seek to the specified offset
        if offset > 0 {
            try self.seek(toOffset: UInt64(offset))
        }
        
        // Calculate the number of bytes to read
        let remainingBytes = fileSize - offset
        let bytesToRead = min(chunkSize, remainingBytes)
        
        // Read the chunk of data
        data = try self.read(upToCount: Int(bytesToRead)) ?? Data()
        
        return data
    }
}
