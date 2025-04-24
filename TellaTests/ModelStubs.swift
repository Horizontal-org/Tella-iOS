//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

extension VaultFileDB {
    
    static func stub() -> VaultFileDB {
        let file = VaultFileDB(id: UUID().uuidString,
                               type: VaultFileType.file,
                               thumbnail: nil,
                               name: "Test",
                               duration: 20,
                               size: 20,
                               mimeType: "application/pdf",
                               width: 12.0,
                               height: 13.0)
        return file
    }

    static func stubFiles() -> [VaultFileDB] {
        return [VaultFileDB.stub(),
                VaultFileDB.stub(),
                VaultFileDB.stub(),
                VaultFileDB.stub(),
                VaultFileDB.stub(),
                VaultFileDB.stub()]
    }
    
}
