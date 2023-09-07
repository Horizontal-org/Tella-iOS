//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class ReportVaultFile : VaultFile {
    
    var instanceId : Int?
    var status : FileStatus?
    var bytesSent : Int = 0
    var createdDate : Date?
    var updatedDate : Date?
    var current : Int = 0

    init(reportFile: ReportFile, vaultFile : VaultFile) {
        super.init(id:vaultFile.id,
                   type: vaultFile.type,
                   fileName: vaultFile.fileName,
                   containerName: vaultFile.containerName,
                   files: vaultFile.files,
                   thumbnail: vaultFile.thumbnail,
                   created: vaultFile.created,
                   fileExtension: vaultFile.fileExtension,
                   size:vaultFile.size,
                   resolution: vaultFile.resolution,
                   duration: vaultFile.duration,
                   pathArray: vaultFile.pathArray)

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
