//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
