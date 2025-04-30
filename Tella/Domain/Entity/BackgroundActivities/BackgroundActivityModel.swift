//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class BackgroundActivityModel {
    
    var id: String
    var name: String = ""
    var type: BackgroundActivityType = .file
    var mimeType: String = ""
    var thumb: Data? = nil
    var status: BackgroundActivityStatus = .inProgress
    
    init(type: BackgroundActivityType) {
        self.id = UUID().uuidString
    }

    init(name: String = "", type: BackgroundActivityType, mimeType: String = "", thumb: Data? = nil, status: BackgroundActivityStatus) {
        self.id = UUID().uuidString
        self.name = name
        self.type = type
        self.mimeType = mimeType
        self.thumb = thumb
        self.status = status
    }
    
    init(vaultFile:VaultFileDB) {
        self.id = vaultFile.id ?? UUID().uuidString
        self.name =  String.init(format: LocalizableBackgroundActivities.encrypting.localized, vaultFile.name)
        self.mimeType = vaultFile.mimeType ?? ""
        self.thumb = vaultFile.thumbnail
    }
}

extension BackgroundActivityModel {
    static func stub() -> BackgroundActivityModel {
        return BackgroundActivityModel(name: "Uploading “Report 345”",
                                       type: .file,
                                       mimeType: "application/pdf",
                                       thumb: nil,
                                       status: .inProgress)
    }
}
