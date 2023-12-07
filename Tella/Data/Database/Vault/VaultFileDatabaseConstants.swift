//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct VaultD {
    
    /* DATABASE */
    static let databaseName = "tella_vault_file.db"
    
    /* DATABASE VERSION */
    
    static let databaseVersion = 1
    
    /* DEFAULT TYPES FOR DATABASE */
    static let integer = " INTEGER "
    static let text = " TEXT ";
    static let blob = " BLOB ";
    static let real = " REAL ";
    
    /* DATABASE TABLES */
    
    static let tVaultFile = "t_vault_file"
    
    /* Root ID */
    static let rootId = "11223344-5566-4777-8899-aabbccddeeff";

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
    static let cWidth = "c_width"
    static let cHeight = "c_height"

}
