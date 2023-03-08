//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


class JoinItem {
    
    var tableName: String
    var columnName : String
    
    init(tableName: String, columnName: String) {
        self.tableName = tableName
        self.columnName = columnName
    }
    
    func format() -> String {
        return (objDoubleQuote(tableName) + "." + objDoubleQuote(columnName))
    }
    
    func objDoubleQuote(_ str: String) -> String {
        return "\"" + str + "\"";
    }
}
