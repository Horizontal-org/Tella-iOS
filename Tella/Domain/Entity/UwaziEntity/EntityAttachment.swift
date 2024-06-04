//
//  EntityAttachment.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/4/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


class EntityAttachment : Codable {
    
    var originalName : String?
    var fileName : String?
    var type : String = "attachment"
    var mimeType : String?
    var entity:  String? = "NEW_ENTITY"
    
    enum CodingKeys:  String,CodingKey {
        case originalName = "originalname"
        case fileName = "filename"
        case type = "type"
        case mimeType = "mimetype"
        case entity = "entity"
    }
    
    init(vaultFile:VaultFileDB) {
        self.originalName =  "\(vaultFile.name).\(vaultFile.fileExtension)"
        self.fileName = "\(vaultFile.name).\(vaultFile.fileExtension)"
        self.mimeType = MIMEType.mime(for: vaultFile.fileExtension)
    }
}

