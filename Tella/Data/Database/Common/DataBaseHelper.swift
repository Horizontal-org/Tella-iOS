//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SQLCipher

class DataBaseHelper {
    
    var dbURL: URL?
    
    var dbPointer: OpaquePointer?
    
    init(key: String?, databaseName: String) throws {
        
        dbURL =  FileManager.documentDirectory(withPath:databaseName)
        
        guard let key = key else {
            throw RuntimeError("Missing database key")
        }
        
        guard let databasePath = dbURL?.path else {
            throw RuntimeError("Missing database path")
        }
        
        if sqlite3_open(databasePath, &dbPointer) != SQLITE_OK {
            debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
            logDbErr()
            closeDatabase()
            throw RuntimeError("Error opening database")
            
        } else {
            debugLog("Opening database at \(dbURL?.absoluteString ?? "")")
        }
        
        var keyBytes = Array(key.utf8)
        defer {
            for index in keyBytes.indices {
                keyBytes[index] = 0
            }
        }
        
        let keyStatus: Int32 = keyBytes.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return SQLITE_MISUSE
            }
            return sqlite3_key(dbPointer, baseAddress, Int32(buffer.count))
        }
        
        if keyStatus != SQLITE_OK {
            logDbErr("Error setting key")
            closeDatabase()
            throw RuntimeError("Error setting key")
        }
        
        enableSQLCipherMemoryProtectionIfAvailable()
    }
    
    deinit {
        closeDatabase()
    }
    
    private func closeDatabase() {
        if dbPointer != nil {
            sqlite3_close(dbPointer)
            dbPointer = nil
        }
    }
    
    private func enableSQLCipherMemoryProtectionIfAvailable() {
        _ = sqlite3_exec(
            dbPointer,
            "PRAGMA cipher_memory_security = ON;",
            nil,
            nil,
            nil
        )
    }
    
    func logDbErr(_ msg: String = "") {
        guard let dbPointer else {
            debugLog("\(msg): database pointer is nil")
            return
        }
        let errmsg = String(cString: sqlite3_errmsg(dbPointer))
        debugLog("\(msg): \(errmsg)")
    }
}


struct SelectQueryItem {
    var tableName: String
    var keyValue: [KeyValue] = []
    var joinCondition: [JoinCondition]? = nil
    
}
