//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

protocol DataModel: Codable {
    func toDomain() -> DomainModel?
}
