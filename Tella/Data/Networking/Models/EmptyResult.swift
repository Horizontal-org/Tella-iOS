//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct EmptyResult:DataModel, Codable {

    func toDomain() -> DomainModel? {
        EmptyDomainModel()
    }
}

class EmptyDomainModel: DomainModel {

    override init() {
    }
}


