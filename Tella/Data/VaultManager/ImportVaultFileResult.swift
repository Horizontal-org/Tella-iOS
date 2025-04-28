//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum ImportVaultFileResult {
    case importProgress(importProgress:ImportProgress)
    case fileAdded([VaultFileDB])
}

