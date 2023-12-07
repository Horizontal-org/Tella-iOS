//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
    case none
}
