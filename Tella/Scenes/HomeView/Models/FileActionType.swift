//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

protocol ActionType {}

enum FileActionType: ActionType {
    case share
    case move
    case rename
    case save
    case info
    case delete
    case edit
    case none
}
