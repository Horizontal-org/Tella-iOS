//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
