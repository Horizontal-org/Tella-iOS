//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct SizeResult:DataModel, Codable {
    
    let size: String?
    
    func toDomain() -> DomainModel? {
        ServerFileSize(size: size)
    }
}
