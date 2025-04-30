//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

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
