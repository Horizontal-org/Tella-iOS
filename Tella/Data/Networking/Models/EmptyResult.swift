//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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


