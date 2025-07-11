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
        
        guard let key = key else { return }
        
        if sqlite3_open(dbURL?.path, &dbPointer) != SQLITE_OK {
            debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
            logDbErr()
            throw  RuntimeError("Error opening database")
            
        } else {
            debugLog("Opening database at \(dbURL?.absoluteString ?? "")")
        }
        
        if (sqlite3_key(dbPointer, key, Int32(key.count)) != SQLITE_OK) {
            logDbErr("Error setting key")
            throw  RuntimeError("Error setting key")
        }
    }
    
    func logDbErr(_ msg: String = "") {
        let errmsg = String(cString: sqlite3_errmsg(dbPointer)!)
        debugLog("\(msg): \(errmsg)")
    }
}


struct SelectQueryItem {
    var tableName: String
    var keyValue: [KeyValue] = []
    var joinCondition: [JoinCondition]? = nil
    
}
