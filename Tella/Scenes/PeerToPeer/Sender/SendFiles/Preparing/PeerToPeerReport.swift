//
//  PeerToPeerReport.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation


class PeerToPeerReport {
    var title : String
    var sessionId : String
    var vaultfiles : [PeerToPeerFile]
    
    init(title: String, sessionId: String, vaultfiles: [PeerToPeerFile]) {
        self.title = title
        self.sessionId = sessionId
        self.vaultfiles = vaultfiles
    }
}

class PeerToPeerFile {
    var fileId : String
    var transmissionId : String?
    var vaultFile : VaultFileDB
    var url : URL?
    
    init(fileId: String, transmissionId: String? = nil, vaultFile: VaultFileDB) {
        self.fileId = fileId
        self.transmissionId = transmissionId
        self.vaultFile = vaultFile
    }
}
