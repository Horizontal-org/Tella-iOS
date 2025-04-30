//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
class FileDTO: Codable, DataModel {
    let id, fileName, bucket, type: String?
    let fileInfo: String?
    
    func toDomain() -> DomainModel? {
        return FileAPI(id: id, fileName: fileName)
    }

}

// MARK: - BoolResponse

class BoolResponse: DataModel, Codable {
    let success: Bool?
    
    func toDomain() -> DomainModel? {
        return BoolModel(success: success)
    }

}

