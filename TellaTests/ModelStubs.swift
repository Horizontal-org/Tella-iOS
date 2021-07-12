//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

extension VaultFile {
    
    static func stub(type: FileType) -> VaultFile {
        let file = VaultFile(type: type, fileName: UUID().uuidString, containerName: UUID().uuidString, files: nil)
        return file
    }

    static func stubFiles() -> [VaultFile] {
        return [VaultFile.stub(type: .audio),
                VaultFile.stub(type: .video),
                VaultFile.stub(type: .folder),
                VaultFile.stub(type: .document),
                VaultFile.stub(type: .document),
                VaultFile.stub(type: .image)]
    }
    
}
