//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

// MARK: - SubmitReportResult
struct SubmitReportResult:DataModel, Codable {
    
    let id, title, welcomeDescription, createdAt: String?
    let deviceInfo: String?
    let author: AuthorDTO?

    enum CodingKeys: String, CodingKey {
        case id, title
        case welcomeDescription = "description"
        case createdAt, deviceInfo, author
    }
    
    func toDomain() -> DomainModel? {
        ReportAPI(id: id)
    }

}

