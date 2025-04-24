//
//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation


extension Set {

    mutating func insert(_ newMembers: [Element]) {
        
        newMembers.forEach { (member) in
            self.insert(member)
        }
    }
}
