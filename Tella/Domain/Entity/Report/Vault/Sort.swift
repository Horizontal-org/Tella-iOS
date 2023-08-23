//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class Sort {
    
    enum SortDirection : String {
        case asc = "ASC"
        case desc = "DESC"
    }
    enum SortType : String {
        case date  = "DATE"
        case name = "NAME"
    }
    
    var  direction: SortDirection
    var  type : SortType
    
    init(direction: SortDirection, type: SortType) {
        self.direction = direction
        self.type = type
    }
}
