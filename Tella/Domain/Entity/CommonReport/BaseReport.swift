//
//  BaseReport.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class BaseReport : Hashable, Codable {
    
    var id : Int?
    var title : String?
    var description : String?
    var createdDate : Date?
    var updatedDate : Date?
    var status : ReportStatus = .unknown
    var reportFiles : [ReportFile]?
    var serverId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_report_id"
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
         vaultFiles: [ReportFile]? = nil,
         serverId: Int?) {
        
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.status = status
        self.reportFiles = vaultFiles
        self.serverId = serverId
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
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        
        let createdDate = try container.decodeIfPresent(Double.self, forKey: .createdDate)
        self.createdDate = createdDate?.getDate()
        
        let updatedDate = try container.decodeIfPresent(Double.self, forKey: .updatedDate)
        self.updatedDate = updatedDate?.getDate()
        
        let status = try container.decodeIfPresent(Int.self, forKey: .status)
        self.status = ReportStatus(rawValue: status ?? ReportStatus.unknown.rawValue) ?? ReportStatus.unknown
        
        self.serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
    }

    static func == (lhs: BaseReport, rhs: BaseReport) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

