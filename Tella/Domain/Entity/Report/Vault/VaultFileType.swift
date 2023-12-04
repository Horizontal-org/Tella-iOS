//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


enum VaultFileType : Int, Codable {
    
    case unknown = 0
    case file = 1
    case directory = 2
    
    init(fromRawValue: Int) {
        self = VaultFileType(rawValue: fromRawValue) ?? .unknown
    }
}
