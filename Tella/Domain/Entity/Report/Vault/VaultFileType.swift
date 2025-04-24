//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
