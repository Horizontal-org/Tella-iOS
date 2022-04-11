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

var firstFileActionItems : [ListActionSheetItem] = [
    
    ListActionSheetItem(imageName: "share-icon",
                        content: "Share",
                        type: FileActionType.share)
]

var secondFileActionItems : [ListActionSheetItem] = [
    
    ListActionSheetItem(imageName: "move-icon",
                        content: "Move to another folder",
                        type: FileActionType.move),
    
    ListActionSheetItem(imageName: "edit-icon",
                        content: "Rename",
                        type: FileActionType.rename),
    
    ListActionSheetItem(imageName: "save-icon",
                        content: "Save to device",
                        type: FileActionType.save),
    
    ListActionSheetItem(imageName: "info-icon",
                        content: "File information",
                        type: FileActionType.info),
    
    ListActionSheetItem(imageName: "delete-icon",
                        content: "Delete",
                        type: FileActionType.delete)
]
