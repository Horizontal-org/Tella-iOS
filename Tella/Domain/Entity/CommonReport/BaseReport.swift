//
//  BaseReport.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

protocol BaseReportProtocol: Hashable {
    var id: Int? { get }
    var title: String? { get }
    var description: String? { get }
    var createdDate: Date? { get }
    var updatedDate: Date? { get }
    var status: ReportStatus { get }
    var reportFiles: [ReportFile]? { get }
    
    var getReportDate: String { get }
}

class BaseReport : Hashable, Codable, BaseReportProtocol {
    
    var id : Int?
    var title : String?
    var description : String?
    var createdDate : Date?
    var updatedDate : Date?
    var status : ReportStatus = .unknown
    var reportFiles : [ReportFile]?
    var serverId: Int?

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case title = "c_title"
        case description = "c_description"
        case createdDate = "c_created_date"
        case updatedDate = "c_updated_date"
        case status = "c_status"
        case serverId = "c_server_id"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         vaultFiles: [ReportFile]? = nil) {
        
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.status = status
        self.reportFiles = vaultFiles
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(createdDate?.getDateDouble() ?? Date().getDateDouble(), forKey: .createdDate)
        try container.encode(updatedDate?.getDateDouble() ?? Date().getDateDouble(), forKey: .updatedDate)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(serverId, forKey: .serverId)
    }
    
    static func == (lhs: BaseReport, rhs: BaseReport) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension BaseReport {
    var getReportDate: String {
        let status = self.status
        
        switch status {
        case .draft:
            return self.createdDate?.getDraftReportTime() ?? ""
        case .submissionPaused:
            return "Paused"
            
        case .submissionInProgress:
            return ""
            
        case .submitted:
            return self.createdDate?.getSubmittedReportTime() ?? ""
        default:
            return ""
            
        }
    }
}
