//
//  UwaziEntityInstance.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


class UwaziEntityInstance: Codable {
    
    var id: Int?
    var templateId: Int?
    var metadata: [String : Any] = [:]
    var status : EntityStatus = EntityStatus.unknown
    var title: String?
    var type: String = "entity"
    var updatedDate: Date?
    var server: UwaziServer?
    var collectedTemplate: CollectedTemplate?
    
    var attachments: Set<VaultFileDB> = []
    var documents: Set<VaultFileDB> = []
    var files: [UwaziEntityInstanceFile] = []
    
    init() {
        
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case templateId = "c_local_template_id"
        case metadata = "c_metadata"
        case status = "c_status"
        case title = "c_title"
        case type = "c_type"
        case updatedDate = "c_updated_date"
        case serverId = "c_server_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metadata.jsonString, forKey: .metadata)
        try container.encode(status, forKey: .status)
        try container.encode(title, forKey: .title)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(type, forKey: .type)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(server?.id, forKey: .serverId)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        
        self.templateId = try container.decode(Int.self, forKey: .templateId)
        
        let metadataString = try container.decode(String.self, forKey: .metadata)
        
        var dictionnary = metadataString.dictionnary
        
        dictionnary.forEach { (key, value) in
            let valuestr = value as? String
            dictionnary[key] = valuestr?.arraydDictionnary
        }
        
        self.metadata = dictionnary
        
        let status = try container.decode(Int.self, forKey: .status)
        self.status = EntityStatus(rawValue: status) ?? EntityStatus.unknown
                
        let updatedDate = try container.decode(Double.self, forKey: .updatedDate)
        self.updatedDate = updatedDate.getDate()
        
        self.title = try container.decode(String.self, forKey: .title)
    }
}
