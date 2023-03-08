//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

protocol DataModel:Codable {
    func toDomain() -> DomainModel?
}
