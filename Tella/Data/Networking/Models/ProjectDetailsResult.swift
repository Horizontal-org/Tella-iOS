//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

// MARK: - ProjectDetailsResult
class ProjectDetailsResult: DataModel, Codable {
    
    let id, name, slug: String?
    let url: String?
    let reports: [ReportDTO?]?
    let createdAt: String?
    
    func toDomain() -> DomainModel? {
        return ProjectAPI(id: id, slug: slug, name: name)
    }
}

// MARK: - Report
class ReportDTO: Codable {
    let id, title, reportDescription, createdAt: String?
    let deviceInfo: String?
    let files: [FileDTO]?
    let author: AuthorDTO?

    enum CodingKeys: String, CodingKey {
        case id, title
        case reportDescription = "description"
        case createdAt, deviceInfo, files, author
    }
}

// MARK: - Author
class AuthorDTO: Codable {
    let id, username, role, createdAt: String?
}

// MARK: - File
class FileDTO: Codable {
    let id, fileName, bucket, type: String?
    let fileInfo: String?
}

// MARK: - BoolResponse

class BoolResponse: Codable {
    let success: Bool?
}

