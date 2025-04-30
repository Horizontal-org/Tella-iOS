//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


class JoinCondition {
    
    var tableName :String
    var firstItem : JoinItem
    var secondItem : JoinItem
    
    init(tableName: String, firstItem: JoinItem, secondItem: JoinItem) {
        self.tableName = tableName
        self.firstItem = firstItem
        self.secondItem = secondItem
    }
}
