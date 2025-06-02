//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


class KeyValue {
    var key : String
    var value : Any?
    var sqliteOperator : SQliteOperator
    
    init(key: String, value: Any? = nil, sqliteOperator: SQliteOperator = .empty) {
        self.key = key
        self.value = value
        self.sqliteOperator = sqliteOperator
    }

}


struct KeyValues {
    var key : String
    var value : [Any]
    
    var sqliteOperator : SQliteOperator

    
    init(key: String, value: [Any], sqliteOperator: SQliteOperator = .empty) {
        self.key = key
        self.value = value
        self.sqliteOperator = sqliteOperator
    }
}

enum SQliteOperator: String {
    case empty = " "
    case and = " AND "
    case or = " OR "
}

