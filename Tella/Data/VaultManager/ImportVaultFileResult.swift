//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum ImportVaultFileResult {
    case importProgress(importProgress:ImportProgress)
    case fileAdded([VaultFileDB])
}

