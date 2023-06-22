//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher

class DataBaseHelper {
    
    var dbURL: URL?
    
    var dbPointer: OpaquePointer?

    func openDatabases(key: String?) { 
        
        dbURL =  FileManager.documentDirectory(withPath: D.databaseName)
        
        guard let key = key else { return }
        
        if sqlite3_open(dbURL?.path, &dbPointer) != SQLITE_OK {
            debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
            logDbErr("Error opening database")
        } else {
            debugLog("Opening database at \(dbURL?.absoluteString ?? "")")
        }
        
//        if (sqlite3_key(dbPointer, key, Int32(key.count)) != SQLITE_OK) {
//            logDbErr("Error setting key")
//        }
    }

    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(dbPointer)!)
        debugLog("\(msg): \(errmsg)")
    }
}


struct SelectQueryItem {
    var tableName: String
    var keyValue: [KeyValue] = []
    var joinCondition: [JoinCondition]? = nil
    
}
