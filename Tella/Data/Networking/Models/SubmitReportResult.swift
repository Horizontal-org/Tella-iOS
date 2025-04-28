//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

// MARK: - SubmitReportResult
class SubmitReportResult: DataModel {
    
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

