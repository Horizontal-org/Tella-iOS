//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

extension VaultFileDB {
    
    static func stub() -> VaultFileDB {
        let file = VaultFileDB(type: VaultFileType.file,
                               hash: nil,
                               metadata: nil,
                               thumbnail: nil,
                               name: "Test",
                               duration: 20,
                               anonymous: true,
                               size: 20,
                               mimeType: "application/pdf")
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
