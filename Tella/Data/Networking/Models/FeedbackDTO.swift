//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct FeedbackDTO: DataModel, Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    let text, platform: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case text, platform
    }
    
    func toDomain() -> DomainModel? {
        return FeedbackAPI(id: id)
    }

}


