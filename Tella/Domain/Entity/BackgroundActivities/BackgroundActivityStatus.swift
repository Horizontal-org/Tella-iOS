//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum BackgroundActivityStatus {
    case inProgress
//    case completed
    case completed(VaultFileDB)

    case failed
}
