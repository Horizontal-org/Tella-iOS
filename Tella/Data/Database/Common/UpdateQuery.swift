//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UpdateQuery {
    
    var tableName:String?
    var valuesToUpdate : [KeyValue] = []
    var equalCondition: [KeyValue] = []
    var inCondition: [KeyValues] = []
    
    /// This function returns the update  query string after concatenating  the join, where, sort and limit conditions
    /// - Returns: The update query string
    @UpdateQueryStringBuilder func getString() -> String {
        getUpdateString()
        " WHERE "
        getEqualConditionString()
        getInConditionString()
    }

    func getUpdateString() -> String {
        
        let keyValue = valuesToUpdate.compactMap({$0})
        let setColumnNames = keyValue.compactMap{($0.key)}
        
        var updateSql = "UPDATE \(tableName ?? "") SET "
        
        updateSql  += setColumnNames.map { "\($0) = :\($0)" }.joined(separator: ", ")
        
        return updateSql
    }
    
    func getEqualConditionString() -> String {
        if !equalCondition.isEmpty {
            let result = equalCondition.compactMap ({ "\($0.sqliteOperator.rawValue) \($0.key) = :\($0.key)" }).joined(separator: " ")
            return " \(result)"
        }
        return ""
    }
    
    func getInConditionString() -> String {
        
        var sqlString = ""
        
        for condition in inCondition {
            
            sqlString += condition.sqliteOperator.rawValue
            
            
            let columnName = condition.key
            let values = condition.value.map { "'\($0)'" }.joined(separator: ", ")
            
            sqlString += " \(columnName) IN (\(values))"
        }
        return sqlString
    }
}

extension UpdateQuery {
    
    class Builder {
        
        private var updateQuery = UpdateQuery()
        
        func setTableName(_ tableName: String) -> Builder {
            updateQuery.tableName = tableName
            return self
        }
        
        func setValuesToUpdate(_ valuesToUpdate: [KeyValue]) -> Builder {
            updateQuery.valuesToUpdate = valuesToUpdate
            return self
        }
        
        func setEqualCondition(_ equalCondition: [KeyValue]) -> Builder {
            updateQuery.equalCondition = equalCondition
            return self
        }
        
        
        func setInCondition(_ inCondition: [KeyValues]) -> Builder {
            updateQuery.inCondition = inCondition
            return self
        }
        
        func build() -> UpdateQuery {
            return updateQuery
        }
    }
}

@resultBuilder
struct UpdateQueryStringBuilder {
    
    static func buildBlock(_ conditions: String...) -> String {
        conditions.joined(separator: " ")
    }
}
