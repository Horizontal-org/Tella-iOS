//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct VaultD {
    
    /* DATABASE */
    static let databaseName = "tella_vault_file.db"
    
    /* DATABASE VERSIO */
    
    static let databaseVersion = 1
    
    /* DEFAULT TYPES FOR DATABASE */
    static let integer = " INTEGER "
    static let text = " TEXT ";
    static let blob = " BLOB ";
    static let real = " REAL ";
    
    /* DATABASE TABLES */
    
    static let tVaultFile = "t_vault_file"
    
    /* DATABASE COLUMNS */
    static let cId = "c_id"
    static let cParentId = "c_parent_id"
    static let cType = "c_type"
    static let cHash = "c_hash"
    static let cMetadata = "c_metadata"
    static let cThumbnail = "c_thumbnail"
    static let cName = "c_name"
    static let cCreated = "c_created"
    static let cDuration = "c_duration"
    static let cAnonymous = "c_anonymous"
    static let cSize = "c_size"
    static let cMimeType = "c_mime_type"
}
