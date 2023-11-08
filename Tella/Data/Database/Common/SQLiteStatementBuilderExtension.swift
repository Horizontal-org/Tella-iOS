//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

import SQLite3

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

extension SQLiteStatementBuilder  {
    
    func query(stmt: OpaquePointer) -> [[String: Any]] {
        var rows = [[String: Any]]()
        var fetchColumnInfo = true
        var columnCount: CInt = 0
        var columnNames = [String]()
        var columnTypes = [CInt]()
        var result = sqlite3_step(stmt)
        while result == SQLITE_ROW {
            
            if fetchColumnInfo {
                columnCount = sqlite3_column_count(stmt)
                for index in 0..<columnCount {
                    
                    let name = sqlite3_column_name(stmt, index)
                    columnNames.append(String(validatingUTF8: name!)!)
                    columnTypes.append(sqlite3_column_type(stmt, index))
                }
                fetchColumnInfo = false
            }
            var row = [String: Any]()
            for index in 0..<columnCount {
                let key = columnNames[Int(index)]
                let type = columnTypes[Int(index)]
                if let val = getColumnValue(index: index, type: type, stmt: stmt) {
                    row[key] = val
                }
            }
            rows.append(row)
            // Next row
            result = sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        return rows
    }
    
    private func getColumnValue(index: CInt, type: CInt, stmt: OpaquePointer) -> Any? {
        
        switch type {
            
        case SQLITE_INTEGER:
            let val = sqlite3_column_int64(stmt, index)
            return Int(val)
            
            
        case SQLITE_FLOAT:
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
            
        case SQLITE_BLOB:
            
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes: data, length: Int(size))
            return val
            
        case SQLITE_TEXT:
            
            if let ptr = UnsafeRawPointer(sqlite3_column_text(stmt, index)) {
                let uptr = ptr.bindMemory(to: CChar.self, capacity: 0)
                let txt = String(validatingUTF8: uptr)
                return txt
            }
            return nil
            
        default:
            return nil
        }
    }
    
    public func bind(insertStatement: OpaquePointer?, _ values: [KeyValue]) -> OpaquePointer? {
        
        for keyValue in values {
            
            let idx = sqlite3_bind_parameter_index(insertStatement, (":" + keyValue.key))
            
            guard idx > 0 else {
                return nil
            }
            let flag = bind(insertStatement: insertStatement, keyValue.value, atIndex: Int(idx))
            
            if flag != SQLITE_OK {
                sqlite3_finalize(insertStatement)
                return nil
            }
        }
        
        return insertStatement
    }
    
    fileprivate func bind(insertStatement: OpaquePointer?, _ value: Any?, atIndex idx: Int) -> CInt {
        
        var flag: CInt = 0
        
        if value == nil {
            flag = sqlite3_bind_null(insertStatement, Int32(idx))
        }  else if let value = value as? Double {
            flag = sqlite3_bind_double(insertStatement, Int32(idx), value)
        } else if let value = value as? Int64 {
            flag = sqlite3_bind_int64(insertStatement, Int32(idx), value)
        } else if let value = value as? String {
            flag = sqlite3_bind_text(insertStatement, Int32(idx), value, -1, SQLITE_TRANSIENT)
        } else if let value = value as? Int {
            flag = self.bind(insertStatement: insertStatement, value.datatypeValue, atIndex: idx)
        } else if let value = value as? Bool {
            flag = self.bind(insertStatement: insertStatement, value.datatypeValue, atIndex: idx)
        } else if let value = value as? Data {
            value.withUnsafeBytes { buffer in
                let ptr = buffer.baseAddress!
                flag = sqlite3_bind_blob(insertStatement, Int32(idx), ptr, Int32(value.count), SQLITE_TRANSIENT)
             }
        } else if let _ = value {
            return 0
        }
        return flag
    }
    
    func execute(stmt: OpaquePointer, sql: String) -> Int {
        // Step
        let res = sqlite3_step(stmt)
        if res != SQLITE_OK && res != SQLITE_DONE {
            sqlite3_finalize(stmt)
            return 0
        }
        // Is this an insert
        let upp = sql.uppercased()
        var result = 0
        if upp.hasPrefix("INSERT ") {
            let rid = sqlite3_last_insert_rowid(dbPointer)
            result = Int(rid)
        } else if upp.hasPrefix("DELETE") || upp.hasPrefix("UPDATE") {
            var cnt = sqlite3_changes(dbPointer)
            if cnt == 0 {
                cnt += 1
            }
            result = Int(cnt)
        } else {
            result = 1
        }
        // Finalize
        sqlite3_finalize(stmt)
        return result
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw RuntimeError(errorMessage)
        }
        return statement
    }
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(dbPointer)!)
        debugLog("\(msg): \(errmsg)")
    }
}
