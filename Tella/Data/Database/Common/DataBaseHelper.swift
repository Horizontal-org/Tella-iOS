//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class DataBaseHelper {
    
    var dbURL: URL?
    
    var dbPointer: OpaquePointer?
    
    
    func openDatabases(key: String?) { // TO REVIEW
        
        dbURL =  FileManager.documentDirectory(withPath: D.databaseName)
        
        guard let key = key else { return }
        
        if sqlite3_open(dbURL?.path, &dbPointer) != SQLITE_OK {
            debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
            logDbErr("Error opening database")
        } else {
            debugLog("Opening database at \(dbURL?.absoluteString ?? "")")
            
        }
        
        debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
        
        if (sqlite3_key(dbPointer, key, Int32(key.count)) != SQLITE_OK) {
            logDbErr("Error setting key")
        }
    }
    
    func selectQuery(tableName: String, andCondition: [KeyValue] = [], andDifferentCondition: [KeyValue] = [], orCondition: [KeyValue] = [] , inCondition: [KeyValues] = [], notInCondition: [KeyValues] = [] , joinCondition: [JoinCondition]? = nil) throws -> [[String: Any]] {

        
        let selectSql = sql(tableName: tableName, andCondition: andCondition, andDifferentCondition:andDifferentCondition, ordCondition: orCondition, inCondition: inCondition,notInCondition: notInCondition, joinCondition: joinCondition)
        
        debugLog("selectSql \(selectSql)")
        
        guard let selectStatement = try prepareStatement(sql: selectSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        let arrayBinds = andCondition + orCondition
        if let stmt = self.bind(insertStatement: selectStatement, arrayBinds) {
            let rows = self.query(stmt: stmt, sql: selectSql)
            return rows
            
        } else {
            throw SqliteError(message: errorMessage)
        }
    }
    
    func selectUnionQuery(selectQueryItem :[SelectQueryItem]) throws -> [[String: Any]] {
        
        var selectSql = ""
        
        var keyValues : [KeyValue] = []
        
        selectQueryItem.enumerated().forEach { (index,item) in
            selectSql.append(sql(tableName: item.tableName, andCondition: item.keyValue, joinCondition: item.joinCondition))
            
            if index < selectQueryItem.count - 1 {
                selectSql += " UNION "
            }
            keyValues.append(contentsOf: item.keyValue)
        }
        selectSql = "SELECT DISTINCT * FROM (\(selectSql))"
        
        debugLog("selectSql \(selectSql)")
        
        guard let selectStatement = try prepareStatement(sql: selectSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        if let stmt = self.bind(insertStatement: selectStatement, keyValues) {
            let rows = self.query(stmt: stmt, sql: selectSql)
            return rows
            
        } else {
            throw SqliteError(message: errorMessage)
        }
    }
    
    func sql(tableName:String, andCondition: [KeyValue] = [], andDifferentCondition: [KeyValue] = [], ordCondition: [KeyValue] = [] , inCondition: [KeyValues] = [], notInCondition: [KeyValues] = [] , order: String = "", limit: Int = 0, joinCondition: [JoinCondition]? = nil, passedTimeCondition: [KeyValue] = [] ) -> String {
        
        var sql = "SELECT * FROM \(tableName)"
        
        if let joinCondition = joinCondition {
            sql += join(joinCondition: joinCondition)
        }
        
        if !andCondition.isEmpty || !andDifferentCondition.isEmpty || !ordCondition.isEmpty || !inCondition.isEmpty || !passedTimeCondition.isEmpty || !notInCondition.isEmpty{
            let andConditionPrimaryKeyColumnNames = andCondition.compactMap{($0.key)}
            let ordConditionPrimaryKeyColumnNames = ordCondition.compactMap{($0.key)}
            let andDifferentConditionPrimaryKeyColumnNames = andDifferentCondition.compactMap{($0.key)}

            
            sql += " WHERE"
            
            
            for (primaryKeyColumnNameIndex, primaryKeyColumnName) in andConditionPrimaryKeyColumnNames.enumerated() {
                if primaryKeyColumnNameIndex == 0 {
                    sql += " ( "
                }
                sql += "  " + primaryKeyColumnName +  " = :\(primaryKeyColumnName)"
                if primaryKeyColumnNameIndex < andConditionPrimaryKeyColumnNames.count - 1 {
                    sql += "  AND"
                } else {
                    sql += " )"
                    
                }
            }
            
            for (primaryKeyColumnNameIndex, primaryKeyColumnName) in andDifferentConditionPrimaryKeyColumnNames.enumerated() {
                if primaryKeyColumnNameIndex == 0 {
                    sql += " ( "
                }
                sql += "  " + primaryKeyColumnName +  " != :\(primaryKeyColumnName)"
                if primaryKeyColumnNameIndex < andConditionPrimaryKeyColumnNames.count - 1 {
                    sql += "  AND"
                } else {
                    sql += " )"
                    
                }
            }

            if (!andCondition.isEmpty || !andDifferentCondition.isEmpty) && !ordCondition.isEmpty {
                sql += " AND"
            }
            
            for (primaryKeyColumnNameIndex, primaryKeyColumnName) in ordConditionPrimaryKeyColumnNames.enumerated() {
                if primaryKeyColumnNameIndex == 0 {
                    sql += " ( "
                }
                
                sql += "  " + primaryKeyColumnName +  " = :\(primaryKeyColumnName)"
                if primaryKeyColumnNameIndex < ordConditionPrimaryKeyColumnNames.count - 1 {
                    sql += "  OR"
                } else {
                    sql += " ) ;"
                }
            }
            
            for (index, condition) in inCondition.enumerated() {
                //
                sql += "  " + condition.key + " IN " + "( "
                
                condition.value.enumerated().forEach({ (index,item) in
                    
                    sql += "\(item) "
                    
                    if index == condition.value.count - 1 {
                        sql += "  ) "
                    } else {
                        sql += "  , "
                    }
                    
                })
                
                
                if index < inCondition.count - 1 {
                    sql += "  AND"
                }
                
            }
            
            for (index, condition) in notInCondition.enumerated() {
                //
                sql += "  " + condition.key + " NOT IN " + "( "
                
                condition.value.enumerated().forEach({ (index,item) in
                    
                    sql += "\(item) "
                    
                    if index == condition.value.count - 1 {
                        sql += "  ) "
                    } else {
                        sql += "  , "
                    }
                    
                })
                
                
                if index < inCondition.count - 1 {
                    sql += "  AND"
                }
                
            }

            
            if (!andCondition.isEmpty || !ordCondition.isEmpty || !inCondition.isEmpty) && !passedTimeCondition.isEmpty {
                sql += " AND"
            }
            

        }
        
        if !order.isEmpty {
            sql += " ORDER BY \(order)"
        }
        if limit > 0 {
            sql += " LIMIT 0, \(limit)"
        }
        return sql
    }
    
    func join(joinCondition:[JoinCondition]) -> String {
        
        var joinConditionStr : String = " "
        
        joinCondition.forEach { joinCondition in
            
            let condition = "LEFT JOIN " + joinCondition.tableName + " ON " + "(" + joinCondition.firstItem.format() + "=" +  joinCondition.secondItem.format() + ")"
            
            joinConditionStr = joinConditionStr + condition
        }
        
        return joinConditionStr
        
    }
    
    private func query(stmt: OpaquePointer, sql: String) -> [[String: Any]] {
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
    
    func createTable(tableName: String, columns:[String]) {
        
        let sqlExpression = "CREATE TABLE " +
        tableName + " (" +
        columns.joined(separator: ",") +
        ");"

        let ret = sqlite3_exec(dbPointer, sqlExpression, nil, nil, nil)
        
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - \(tableName)")
        }
    }
    
    func insertInto(tableName:String, keyValue: [KeyValue?]) throws -> Int {
        let keyValue = keyValue.compactMap({$0})
        
        let keys = keyValue.compactMap{($0.key)}
        let values = keyValue.compactMap{value in (":\(value.key)") }
        
        let insertSql = "INSERT INTO " + tableName
        + " ( " + keys.joined(separator: ",") + ")"
        + " VALUES "
        + " ( " + values.joined(separator: ",") + " ) "
        
        debugLog("insertSql: \(insertSql)")
        
        guard let insertStatement = try prepareStatement(sql: insertSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        if let stmt = self.bind(insertStatement: insertStatement, keyValue) {
            let result = self.execute(stmt: stmt, sql: insertSql)
            
            if result == 0 {
                throw SqliteError(message: errorMessage)
            }
            
            return result
            
        } else {
            throw SqliteError(message: errorMessage)
        }
    }
    
    
    func update(tableName:String, keyValue: [KeyValue?], primarykeyValue : [KeyValue?] ) throws -> Int {
        let keyValue = keyValue.compactMap({$0})
        let primarykeyValue = primarykeyValue.compactMap({$0})

        let setColumnNames = keyValue.compactMap{($0.key)}
        let primaryKeyColumnNames = primarykeyValue.compactMap{($0.key)}
        
        let bindValues = keyValue + (primarykeyValue)
        
        
        var updateSql = "UPDATE '\(tableName)' SET"
        
        for (columnIndex, columnName) in setColumnNames.enumerated() {
            updateSql += "  \(columnName)  = :\(columnName) "
            if columnIndex < setColumnNames.count - 1 {
                updateSql += ", "
            }
        }
        if !primarykeyValue.isEmpty {
            updateSql += " WHERE"
            for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
                updateSql += "  " + primaryKeyColumnName +  " = :\(primaryKeyColumnName)"
                if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                    updateSql += " AND"
                }
            }
        }
        
        debugLog("update: \(updateSql)")
        
        guard let updateStatement = try prepareStatement(sql: updateSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        if let stmt = self.bind(insertStatement: updateStatement, bindValues) {
            let result = self.execute(stmt: stmt, sql: updateSql)
            
            if result == 0 {
                throw SqliteError(message: errorMessage)
            }
            
            return result
            
        } else {
            throw SqliteError(message: errorMessage)
        }
    }
    
    func delete(tableName:String, primarykeyValue : [KeyValue]) throws -> Int {
        
        let primaryKeyColumnNames = primarykeyValue.compactMap{($0.key)}
        
        var deleteSql = "DELETE FROM '\(tableName)' WHERE"
        for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
            deleteSql += " " + primaryKeyColumnName + " = :\(primaryKeyColumnName)"
            if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                deleteSql += " AND"
            }
        }
        
        debugLog("delete: \(deleteSql)")
        
        guard let deleteStatement = try prepareStatement(sql: deleteSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        if let stmt = self.bind(insertStatement: deleteStatement, primarykeyValue) {
            let result = self.execute(stmt: stmt, sql: deleteSql)
            
            if result == 0 {
                throw SqliteError(message: errorMessage)
            }
            
            return result
            
        } else {
            throw SqliteError(message: errorMessage)
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
        } else if let _ = value {
            return 0
        }
        
        return flag
    }
    
    private func execute(stmt: OpaquePointer, sql: String) -> Int {
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
            throw SqliteError(message: errorMessage)
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


struct SelectQueryItem {
    var tableName: String
    var keyValue: [KeyValue] = []
    var joinCondition: [JoinCondition]? = nil
    
}
