//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class SQLiteStatementBuilder {
    
    var dbPointer: OpaquePointer?
    
    init(dbPointer: OpaquePointer? ) {
        self.dbPointer = dbPointer
    }
    
    func getCurrentDatabaseVersion() throws -> Int? {
        
        guard let selectStatement = try prepareStatement(sql: "PRAGMA user_version") else {
            throw RuntimeError(errorMessage)
        }
        
        let dict =  query(stmt: selectStatement)
        
        guard let dict = dict.first, let userVersion = dict["user_version"] as? Int else { return nil }
        
        return userVersion
        
    }
    
    func setNewDatabaseVersion(version:Int) throws  {
        
        let sql = ("PRAGMA user_version = \(version)")
        
        guard let updateStatement = try prepareStatement(sql:sql ) else {
            throw RuntimeError(errorMessage)
        }
        
        let result = execute(stmt: updateStatement, sql: sql)
        
        if result == 0 {
            throw RuntimeError(errorMessage)
        }
    }
    
    func selectQuery(tableName: String, andCondition: [KeyValue] = [], andDifferentCondition: [KeyValue] = [], orCondition: [KeyValue] = [] , inCondition: [KeyValues] = [], notInCondition: [KeyValues] = [] , joinCondition: [JoinCondition]? = nil) throws -> [[String: Any]] {
        
        
        let selectSql = sql(tableName: tableName, andCondition: andCondition, andDifferentCondition:andDifferentCondition, ordCondition: orCondition, inCondition: inCondition,notInCondition: notInCondition, joinCondition: joinCondition)
        
        debugLog("selectSql \(selectSql)")
        
        guard let selectStatement = try prepareStatement(sql: selectSql) else {
            throw RuntimeError(errorMessage)
        }
        
        let arrayBinds = andCondition + orCondition
        if let stmt = bind(insertStatement: selectStatement, arrayBinds) {
            let rows = query(stmt: stmt)
            return rows
            
        } else {
            throw RuntimeError(errorMessage)
        }
    }
    
    func getSelectQuery(tableName: String,
                        equalCondition: [KeyValue] = [],
                        differentCondition: [KeyValue] = [],
                        inCondition: [KeyValues] = [],
                        notInCondition: [KeyValues] = [] ,
                        sortCondition : [SortCondition] = [],
                        limit: Int = 0,
                        joinCondition: [JoinCondition]? = nil,
                        likeConditions: [KeyValue] = [],
                        notLikeConditions: [KeyValue] = [])  throws -> [[String: Any]] {
        
        let selectSql = sql(tableName: tableName,
                            equalCondition: equalCondition,
                            differentCondition: differentCondition,
                            inCondition: inCondition,
                            notInCondition: notInCondition,
                            sortCondition: sortCondition,
                            limit: limit,
                            joinCondition: joinCondition,
                            likeConditions: likeConditions,
                            notLikeConditions: notLikeConditions)
        
        debugLog("selectSql \(selectSql)")
        
        guard let selectStatement = try prepareStatement(sql: selectSql) else {
            throw RuntimeError(errorMessage)
        }
        
        let arrayBinds = equalCondition + differentCondition
        if let stmt = bind(insertStatement: selectStatement, arrayBinds) {
            let rows = query(stmt: stmt)
            return rows
            
        } else {
            throw RuntimeError(errorMessage)
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
            throw RuntimeError(errorMessage)
        }
        
        if let stmt = bind(insertStatement: selectStatement, keyValues) {
            let rows = query(stmt: stmt)
            return rows
            
        } else {
            throw RuntimeError(errorMessage)
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
            
            
            sql += " WHERE "
            
            if !andCondition.isEmpty {
                let values = andConditionPrimaryKeyColumnNames.map { "\($0) = :\($0)" }.joined(separator: " AND")
                sql += " (\(values))"
            }
            
            if (!andCondition.isEmpty && !andDifferentCondition.isEmpty) {
                sql += " AND"
            }
            
            if !andDifferentCondition.isEmpty {
                let values = andDifferentConditionPrimaryKeyColumnNames.map { "\($0) != :\($0)" }.joined(separator: " AND")
                sql += " (\(values))"
            }
            
            if (!andCondition.isEmpty || !andDifferentCondition.isEmpty) && !ordCondition.isEmpty {
                sql += " AND"
            }
            
            if !ordCondition.isEmpty {
                let values = ordConditionPrimaryKeyColumnNames.map { "\($0) = :\($0)" }.joined(separator: " OR")
                sql += " (\(values))"
            }
            
            if (!andCondition.isEmpty || !andDifferentCondition.isEmpty || !ordCondition.isEmpty) && !inCondition.isEmpty {
                sql += " AND"
            }
            
            for (index, condition) in inCondition.enumerated() {
                
                let columnName = condition.key
                let values = condition.value.map { "\($0)" }.joined(separator: ", ")
                
                sql += " \(columnName) IN (\(values))"
                
                if index < inCondition.count - 1 {
                    sql += "  AND"
                }
            }
            
            if (!andCondition.isEmpty || !andDifferentCondition.isEmpty || !ordCondition.isEmpty || !inCondition.isEmpty) && !notInCondition.isEmpty {
                sql += " AND"
            }
            
            for (index, condition) in notInCondition.enumerated() {
                
                let columnName = condition.key
                let values = condition.value.map { "\($0)" }.joined(separator: ", ")
                
                sql += " \(columnName) NOT IN (\(values))"
                
                if index < notInCondition.count - 1 {
                    sql += "  AND"
                }
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
    
    func sql(tableName:String,
             equalCondition: [KeyValue] = [],
             differentCondition: [KeyValue] = [],
             inCondition: [KeyValues] = [],
             notInCondition: [KeyValues] = [] ,
             sortCondition : [SortCondition] = [],
             limit: Int = 0,
             joinCondition: [JoinCondition]? = nil,
             likeConditions: [KeyValue] = [],
             notLikeConditions: [KeyValue] = []) -> String {
        
        var sql = "SELECT * FROM \(tableName)"
        
        if let joinCondition = joinCondition {
            sql += join(joinCondition: joinCondition)
        }
        
        if !equalCondition.isEmpty || !differentCondition.isEmpty || !inCondition.isEmpty || !notInCondition.isEmpty || !likeConditions.isEmpty || !notLikeConditions.isEmpty {
            
            sql += " WHERE "
            
            if !equalCondition.isEmpty {
                let result = equalCondition.compactMap{("\($0.sqliteOperator.rawValue) \($0.key) = :\($0.key)")}.joined(separator: ", ")
                sql += " \(result)"
            }
            
            if !differentCondition.isEmpty {
                let result = differentCondition.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) != :\($0.key)")}.joined(separator: ", ")
                sql += " \(result)"
            }
            
            for condition in inCondition {
                
                sql += condition.sqliteOperator.rawValue
                
                
                let columnName = condition.key
                let values = condition.value.map { "'\($0)'" }.joined(separator: ", ")
                
                sql += " \(columnName) IN (\(values))"
            }
            
            for condition in notInCondition  {
                
                sql += condition.sqliteOperator.rawValue
                
                let columnName = condition.key
                let values = condition.value.map { "'\($0)'" }.joined(separator: ", ")
                
                sql += " \(columnName) NOT IN (\(values))"
                
            }
            
            if !likeConditions.isEmpty {
                let result = likeConditions.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) LIKE '\($0.value ?? "")'")}.joined(separator: " ")
                sql += " \(result)"
            }
            
            
            if !notLikeConditions.isEmpty {
                let result = notLikeConditions.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) NOT LIKE '\($0.value ?? "")'")}.joined(separator: " ")
                sql += " \(result)"
            }
        }
        
        if !sortCondition.isEmpty {
            let formattedSortCondition = sortCondition.compactMap({"\($0.column) \($0.sortDirection)"}).joined(separator: ", ")
            sql += " ORDER BY \(formattedSortCondition)"
        }
        if limit > 0 {
            sql += " LIMIT \(limit)"
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
    
    func createTable(tableName: String, columns:[String]) {
        
        let sqlExpression = "CREATE TABLE IF NOT EXISTS " +
        tableName + " (" +
        columns.joined(separator: ",") +
        ");"
        
        let ret = sqlite3_exec(dbPointer, sqlExpression, nil, nil, nil)
        
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - \(tableName)")
        }
    }
    
    @discardableResult
    func insertInto(tableName:String, keyValue: [KeyValue?])  throws -> Int {
        let keyValue = keyValue.compactMap({$0})
        
        let keys = keyValue.compactMap{($0.key)}
        let values = keyValue.compactMap{value in (":\(value.key)") }
        
        let insertSql = "INSERT INTO " + tableName
        + " ( " + keys.joined(separator: ",") + ")"
        + " VALUES "
        + " ( " + values.joined(separator: ",") + " ) "
        
        debugLog("insertSql: \(insertSql)")
        
        guard let insertStatement = try prepareStatement(sql: insertSql) else {
            throw RuntimeError(errorMessage)
        }
        
        if let stmt = bind(insertStatement: insertStatement, keyValue) {
            
            let result = execute(stmt: stmt, sql: insertSql)
            
            if result == 0 {
                throw RuntimeError(errorMessage)
            }
            
            return result
            
        } else {
            throw RuntimeError(errorMessage)
        }
    }
    
    @discardableResult
    func update(tableName:String, keyValue: [KeyValue?], primarykeyValue : [KeyValue?] ) throws -> Int {
        
        let keyValue = keyValue.compactMap({$0})
        let primarykeyValue = primarykeyValue.compactMap({$0})
        
        let setColumnNames = keyValue.compactMap{($0.key)}
        let primaryKeyColumnNames = primarykeyValue.compactMap{($0.key)}
        
        let bindValues = keyValue + (primarykeyValue)
        
        var updateSql = "UPDATE \(tableName) SET "
        
        updateSql  += setColumnNames.map { "\($0) = :\($0)" }.joined(separator: ", ")
        
        if !primarykeyValue.isEmpty {
            updateSql += " WHERE "
            updateSql += primaryKeyColumnNames.map { "\($0) = :\($0)" }.joined(separator: " AND ")
        }
        
        debugLog("update: \(updateSql)")
        
        guard let updateStatement = try prepareStatement(sql: updateSql) else {
            throw RuntimeError(errorMessage)
        }
        
        if let stmt = bind(insertStatement: updateStatement, bindValues) {
            
            let result = execute(stmt: stmt, sql: updateSql)
            
            if result == 0 {
                throw RuntimeError(errorMessage)
            }
            return result
            
        } else {
            throw RuntimeError(errorMessage)
        }
    }
    
    func delete(tableName:String, primarykeyValue : [KeyValue] = [], inCondition: [KeyValues] = []) throws {
        
        let primaryKeyColumnNames = primarykeyValue.compactMap{($0.key)}
        
        var deleteSql = "DELETE FROM \(tableName)"
        
        if !primarykeyValue.isEmpty || !inCondition.isEmpty {
            deleteSql  += " WHERE "
        }
        
        deleteSql  += primaryKeyColumnNames.map { "\($0) = :\($0)" }.joined(separator: " AND ")
        
        
        for (index, condition) in inCondition.enumerated() {
            
            let columnName = condition.key
            let values = condition.value.map { "'\($0)'" }.joined(separator: ", ")
            
            deleteSql += " \(columnName) IN (\(values))"
            
            if index < inCondition.count - 1 {
                deleteSql += "  AND"
            }
        }
        
        debugLog("delete: \(deleteSql)")
        
        guard let deleteStatement = try prepareStatement(sql: deleteSql) else {
            throw RuntimeError(errorMessage)
        }
        
        if let stmt = bind(insertStatement: deleteStatement, primarykeyValue) {
            
            let result = execute(stmt: stmt, sql: deleteSql)
            
            if result == 0 {
                throw RuntimeError(errorMessage)
            }
            
        } else {
            throw RuntimeError(errorMessage)
        }
        
    }
    
    func deleteAll(tableNames: [String]) throws {
        
        for tableName in tableNames {
            
            let deleteSql = "DELETE FROM \(tableName)"
            
            debugLog("delete: \(deleteSql)")
            
            guard let deleteStatement = try prepareStatement(sql: deleteSql) else {
                throw RuntimeError(errorMessage)
            }
            
            let deletedCount = execute(stmt: deleteStatement, sql: deleteSql)
            
            if deletedCount == 0 {
                throw RuntimeError(errorMessage)
            }
        }
    }
}


struct SortCondition {
    
    var column : String
    var sortDirection : String
    
}
