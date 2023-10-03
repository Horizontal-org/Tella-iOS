//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

extension VaultFileDB {
    
    static func stub() -> VaultFileDB {
        let file = VaultFileDB(type: VaultFileType.file,
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
