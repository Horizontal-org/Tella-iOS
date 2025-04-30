//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class SelectQuery {
    
    var tableName:String?
    var equalCondition: [KeyValue] = []
    var differentCondition: [KeyValue] = []
    var inCondition: [KeyValues] = []
    var notInCondition: [KeyValues] = []
    var sortCondition : [SortCondition] = []
    var limit: Int?
    var joinCondition: [JoinCondition]? = nil
    var likeConditions: [KeyValue] = []
    var notLikeConditions: [KeyValue] = []
    
    /// This function returns the select query string after concatenating  the join, where, sort and limit conditions
    /// - Returns: The select query string
    @SelectQueryStringBuilder func getString() -> String {
        getSelectString()
        getjoinConditionString()
        whereCondition()
        getSortConditionString()
        getLimitConditionString()
    }
    
    /// This function returns the where condition string after concatenating the equal, different, in, not in, like and not like conditions
    /// - Returns: where condition string
    @SelectQueryStringBuilder func whereConditionString() -> String {
        " WHERE "
        getEqualConditionString()
        getDifferentConditionString()
        getInConditionString()
        getNotInConditionString()
        getLikeConditionsString()
        getNotLikeConditionsString()
    }
    
    func whereCondition() -> String {
        if !equalCondition.isEmpty || !differentCondition.isEmpty || !inCondition.isEmpty || !notInCondition.isEmpty || !likeConditions.isEmpty || !notLikeConditions.isEmpty {
            return whereConditionString()
        }
        return ""
    }
    
    func getSelectString() -> String {
        "SELECT * FROM \(tableName ?? "")"
    }
    
    func getjoinConditionString() -> String {
        
        var joinConditionStr : String = " "
        
        if let joinCondition {
            joinCondition.forEach { joinCondition in
                
                let condition = "LEFT JOIN " + joinCondition.tableName + " ON " + "(" + joinCondition.firstItem.format() + "=" +  joinCondition.secondItem.format() + ") "
                
                joinConditionStr = joinConditionStr + condition
            }
        }
        return joinConditionStr
    }

    func getEqualConditionString() -> String {
        if !equalCondition.isEmpty {
            let result = equalCondition.compactMap{("\($0.sqliteOperator.rawValue) \($0.key) = :\($0.key)")}.joined(separator: ", ")
            return " \(result)"
        }
        return ""
    }
    
    func getDifferentConditionString() -> String {
        if !differentCondition.isEmpty {
            let result = differentCondition.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) != :\($0.key)")}.joined(separator: ", ")
            return   " \(result)"
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
    
    func getNotInConditionString() -> String {
        
        var sqlString = ""
        
        for condition in notInCondition  {
            
            sqlString += condition.sqliteOperator.rawValue
            
            let columnName = condition.key
            let values = condition.value.map { "'\($0)'" }.joined(separator: ", ")
            
            sqlString += " \(columnName) NOT IN (\(values))"
        }
        return sqlString
    }
    
    func getLikeConditionsString() -> String {
        if !likeConditions.isEmpty {
            let result = likeConditions.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) LIKE '\($0.value ?? "")'")}.joined(separator: " ")
            return " \(result)"
        }
        return ""
    }
    
    func getNotLikeConditionsString() -> String {
        if !notLikeConditions.isEmpty {
            let result = notLikeConditions.compactMap{(" \($0.sqliteOperator.rawValue) \($0.key) NOT LIKE '\($0.value ?? "")'")}.joined(separator: " ")
            return " \(result)"
        }
        return ""
    }
    
    func getSortConditionString() -> String {
        if !sortCondition.isEmpty {
            let formattedSortCondition = sortCondition.compactMap({"\($0.column) \($0.sortDirection)"}).joined(separator: ", ")
            return " ORDER BY \(formattedSortCondition)"
        }
        return ""
    }
    
    func getLimitConditionString() -> String {
        if let limit, limit > 0 {
            return " LIMIT \(limit)"
        }
        return ""
    }
}

extension SelectQuery {
    
    class Builder {
        
        private var selectQuery = SelectQuery()
        
        func setTableName(_ tableName: String) -> Builder {
            selectQuery.tableName = tableName
            return self
        }
        
        func setEqualCondition(_ equalCondition: [KeyValue]) -> Builder {
            selectQuery.equalCondition = equalCondition
            return self
        }
        
        func setDifferentCondition(_ differentCondition: [KeyValue]) -> Builder {
            selectQuery.differentCondition = differentCondition
            return self
        }
        
        func setInCondition(_ inCondition: [KeyValues]) -> Builder {
            selectQuery.inCondition = inCondition
            return self
        }
        
        func setNotInCondition(_ notInCondition: [KeyValues]) -> Builder {
            selectQuery.notInCondition = notInCondition
            return self
        }
        
        func setSortCondition(_ sortCondition: [SortCondition]) -> Builder {
            selectQuery.sortCondition = sortCondition
            return self
        }
        
        func setLimit(_ limit: Int?) -> Builder {
            selectQuery.limit = limit
            return self
        }
        
        func setJoinCondition(_ joinCondition: [JoinCondition]?) -> Builder {
            selectQuery.joinCondition = joinCondition
            return self
        }
        
        func setLikeConditions(_ likeConditions: [KeyValue]) -> Builder {
            selectQuery.likeConditions = likeConditions
            return self
        }
        
        func setNotLikeConditions(_ notLikeConditions: [KeyValue]) -> Builder {
            selectQuery.notLikeConditions = notLikeConditions
            return self
        }
        
        func build() -> SelectQuery {
            return selectQuery
        }
    }
}

@resultBuilder
struct SelectQueryStringBuilder {
    
    static func buildBlock(_ conditions: String...) -> String {
        conditions.joined(separator: " ")
    }
}
