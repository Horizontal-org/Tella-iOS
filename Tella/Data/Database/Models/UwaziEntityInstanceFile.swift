//
//  File.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziEntityInstanceFile: Codable {
    
    var id: Int?
    var vaultFileInstanceId: String?
    var status : FileStatus?
    var entityInstanceId : Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case vaultFileInstanceId = "c_vault_file_instance_id"
        case status = "c_status"
        case entityInstanceId = "c_uwazi_entity_instance_id"
    }
    init(id: Int? = nil, vaultFileInstanceId: String? = nil, status: FileStatus? = .notSubmitted, entityInstanceId: Int? = nil) {
        self.id = id
        self.vaultFileInstanceId = vaultFileInstanceId
        self.status = status
        self.entityInstanceId = entityInstanceId
    }
}
