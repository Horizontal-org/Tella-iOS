//
//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


extension Set {

    mutating func insert(_ newMembers: [Element]) {
        
        newMembers.forEach { (member) in
            self.insert(member)
        }
    }
}
