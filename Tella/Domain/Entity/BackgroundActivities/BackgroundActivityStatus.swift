//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum BackgroundActivityStatus {
    case inProgress
//    case completed
    case completed(VaultFileDB)

    case failed
}
