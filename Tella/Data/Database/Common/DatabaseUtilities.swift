//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3

extension TellaDataBase {

    func cddl(_ columnName: String, _ columnType: String,  primaryKey : Bool ,  autoIncrement : Bool) -> String {
        return columnName + " " + columnType + (primaryKey ?  " PRIMARY KEY "  : "") +  (autoIncrement ? " AUTOINCREMENT " : "");
    }
    
    func cddl(_ columnName: String, _ columnType: String) -> String {
        return columnName + " " + columnType;
    }
    func cddl(_ columnName: String, _ columnType: String, defaultValue: String) -> String {
        return columnName + " " + columnType //+ "DEFAULT" + defaultValue
    }
    
    func cddl(_ columnName: String, _ columnType: String, _ notNull: Bool) -> String {
        return  (columnName) + " " + columnType + (notNull ? " NOT NULL" : "")
    }
    
    func cddl(_ columnName: String, _ columnType: String, _ notNull: Bool, _ defaultValue: Int) -> String {
        return columnName + " " + columnType + (notNull ? " NOT NULL " : "") + "DEFAULT " + "\(defaultValue)";
    }
    
    
    func cddl(_ columnName: String, _ columnType: String,  tableName : String ,  referenceKey : String) -> String {
        return columnName + " " + columnType + ", FOREIGN KEY" + " (" + columnName + ") " + " REFERENCES "   +  tableName + "(" + referenceKey + ")";
    }
    
    
    func sq(_ text: String) -> String {
        return " " + text + " ";
    }
    
    func objQuote(_ str: String) -> String {
        return "'" + str + "'";
    }
    
    func objDoubleQuote(_ str: String) -> String {
        return "\"" + str + "\"";
    }
    
    
    
    func comma() -> String {
        return " , ";
    }
    
    
}
