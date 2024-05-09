//
//  File.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziEntityInstanceFile: Codable, Hashable {
   
    static func == (lhs: UwaziEntityInstanceFile, rhs: UwaziEntityInstanceFile) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    
    
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

class UwaziVaultFile : VaultFileDB {
    
    var instanceId : Int?
    var status : FileStatus?
    
    init(uwaziFile: UwaziEntityInstanceFile, vaultFile : VaultFileDB) {
        
        super.init(id:vaultFile.id,
                   type: vaultFile.type,
                   thumbnail: vaultFile.thumbnail,
                   name: vaultFile.name,
                   duration: vaultFile.duration,
                   size: vaultFile.size,
                   mimeType: vaultFile.mimeType,
                   width: vaultFile.width,
                   height: vaultFile.height)
        
        self.instanceId = uwaziFile.id
        self.status = uwaziFile.status
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
    }
}

extension UwaziVaultFile  {
    var statusIcon: String? {
        switch status {
        case .submitted:
            return "report.submitted"
        default:
            return nil
        }
    }
}
