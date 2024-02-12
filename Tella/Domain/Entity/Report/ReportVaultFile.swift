//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class ReportVaultFile : VaultFileDB {
    
    var instanceId : Int?
    var status : FileStatus?
    var bytesSent : Int = 0
    var createdDate : Date?
    var updatedDate : Date?
    var current : Int = 0
    
    init(reportFile: ReportFile, vaultFile : VaultFileDB) {
        
        super.init(id:vaultFile.id,
                   type: vaultFile.type,
                   thumbnail: vaultFile.thumbnail,
                   name: vaultFile.name,
                   duration: vaultFile.duration,
                   size: vaultFile.size,
                   mimeType: vaultFile.mimeType,
                   width: vaultFile.width,
                   height: vaultFile.height)
        
        self.instanceId = reportFile.id
        self.status = reportFile.status
        self.bytesSent = reportFile.bytesSent ?? 0
        self.createdDate = reportFile.createdDate
        self.updatedDate = reportFile.updatedDate
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
    }
}
