//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import os.log
import SQLite3
import SQLCipher

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class TellaDataBase {
    
    var dbURL: URL?
    
    private var dbPointer: OpaquePointer?
    
    init(key: String?) {
        
        dbURL =  FileManager.documentDirectory(withPath: D.databaseName)
        
        openDatabase(key: key)
        
        createTables()
    }
    
    func openDatabase(key: String?) { // TO REVIEW
        
        guard let key = key else { return }
        
        if sqlite3_open(dbURL?.path, &dbPointer) != SQLITE_OK {
            debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
            logDbErr("Error opening database")
        } else {
            print("Opening database at \(dbURL?.absoluteString ?? "")")
            
        }
        
        debugLog("Error opening database at \(dbURL?.absoluteString ?? "")!")
        
        //        guard let key = key else { return }
        
        if (sqlite3_key(dbPointer, key, Int32(key.count)) != SQLITE_OK) {
            logDbErr("Error setting key")
        }
    }
    
    func createTables() {
        createServerTable()
        createReportTable()
        createReportFilesTable()
    }
    
    func addServer(server : Server) throws -> Int  {
        return try insertInto(tableName: D.tServer, keyValue: [KeyValue(key: D.cName, value: server.name),
                                                               KeyValue(key: D.cURL, value: server.url),
                                                               KeyValue(key: D.cUsername, value: server.username),
                                                               KeyValue(key: D.cPassword, value: server.password)])
        
    }
    
    func getServer() -> [Server] {
        var servers : [Server] = []
        do {
            let serversDict = try selectQuery(tableName: D.tServer, keyValue: [])
            
            serversDict.forEach { dict in
                guard let id = dict[D.cId] as? Int,
                      let name = dict[D.cName] as? String,
                      let url = dict[D.cURL] as? String,
                      let username = dict[D.cUsername] as? String,
                      let password = dict[D.cPassword] as? String
                else {
                    return
                }
                
                servers.append( Server(id:id,
                                       name: name,
                                       url: url,
                                       username: username,
                                       password: password))
            }
            
            return servers
            
        } catch {
            return []
        }
        
    }
    
    func getReports()  {
        
    }
    
    func addReport() {
    }
    
    func updateReport()   {
        
    }
    
    func sql(tableName:String, filter: String = "", order: String = "", limit: Int = 0) -> String {
        
        var sql = "SELECT * FROM \(tableName)"
        
        if !filter.isEmpty {
            sql += " WHERE \(filter)"
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
        
        var joinConditionStr : String = ""
        
        joinCondition.forEach { joinCondition in
            
            let condition = "INNER JOIN" + joinCondition.tableName + "ON" + "(" + joinCondition.firstItem.format() + "=" +  joinCondition.secondItem.format() + ")"
            
            joinConditionStr = joinConditionStr + condition
        }
        
        return joinConditionStr
        
    }
    
    func selectQuery(tableName: String, keyValue: [KeyValue]) throws -> [[String: Any]] {
        
        let selectSql = sql(tableName: tableName)
        
        guard let selectStatement = try prepareStatement(sql: selectSql) else {
            throw SqliteError(message: errorMessage)
        }
        
        if let stmt = self.bind(insertStatement: selectStatement, keyValue) {
            let rows = self.query(stmt: stmt, sql: selectSql)
            return rows
            
        } else {
            throw SqliteError(message: errorMessage)
        }
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
                    //                        NSLog("Column type:\(type) with value:\(val)")
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
        
        if type == SQLITE_INTEGER {
            let val = sqlite3_column_int64(stmt, index)
            return Int(val)
        }
        if type == SQLITE_FLOAT {
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
        }
        
        if type == SQLITE_BLOB {
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes: data, length: Int(size))
            return val
        }
        
        if type == SQLITE_NULL {
            return nil
        }
        
        if let ptr = UnsafeRawPointer(sqlite3_column_text(stmt, index)) {
            let uptr = ptr.bindMemory(to: CChar.self, capacity: 0)
            let txt = String(validatingUTF8: uptr)
            return txt
        }
        return nil
    }
    
    func createServerTable() {
        // c_id | c_name | c_url | c_username | c_password
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text)]
        createTable(tableName: D.tServer, columns: columns)
    }
    
    func createReportTable() {
        // c_id | c_title | c_description | c_date | cStatus | c_server_id
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cDate, D.text),
            cddl(D.cStatus, D.text),
            cddl(D.cServerId, D.text, tableName: D.tServer, referenceKey: D.cId)
        ]
        createTable(tableName: D.tReport, columns: columns)
    }
    
    func createReportFilesTable() {
        // c_id | c_vaultFile_id | c_report_id
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileId, D.integer),
            cddl(D.cReportId, D.integer, tableName: D.tReport, referenceKey: D.cId)]
        createTable(tableName: D.tReportFiles, columns: columns)
    }
}

extension TellaDataBase {
    
    func createTable(tableName: String, columns:[String]) {
        
        let sqlExpression = "CREATE TABLE " +
        tableName + " (" +
        columns.joined(separator: comma()) +
        ");"
        
        let ret = sqlite3_exec(dbPointer, sqlExpression, nil, nil, nil)
        
        print("sqlExpression",sqlExpression)
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - Records")
        }
    }
    
    func insertInto(tableName:String, keyValue: [KeyValue]) throws -> Int {
        
        let keys = keyValue.compactMap{($0.key)}
        let values = keyValue.compactMap{value in (":\(value.key)") }
        
        let insertSql = "INSERT INTO " + tableName
        + " ( " + keys.joined(separator: comma()) + ")"
        + " VALUES "
        + " ( " + values.joined(separator: comma()) + " ) "
        
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

// MARK: -

extension Bool {
    
    public var datatypeValue: Int64 {
        self ? 1 : 0
    }
    
}

extension Int {
    
    public var datatypeValue: Int64 {
        Int64(self)
    }
    
}
