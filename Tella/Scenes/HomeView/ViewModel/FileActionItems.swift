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
                        content: LocalizableVault.moreActionsShareSheetSelect.localized,
                        type: FileActionType.share)
]

var secondFileActionItems : [ListActionSheetItem] = 
    
      [ListActionSheetItem(imageName: "move-icon",
                                content: LocalizableVault.moreActionsMoveSheetSelect.localized,
                                type: FileActionType.move),
            
            ListActionSheetItem(imageName: "edit-icon",
                                content: LocalizableVault.moreActionsRenameSheetSelect.localized,
                                type: FileActionType.rename),
            
            ListActionSheetItem(imageName: "save-icon",
                                content: LocalizableVault.moreActionsSaveSheetSelect.localized,
                                type: FileActionType.save),
            
            ListActionSheetItem(imageName: "info-icon",
                                content: LocalizableVault.moreActionsFileInformationSheetSelect.localized,
                                type: FileActionType.info),
            
            ListActionSheetItem(imageName: "delete-icon",
                                content: LocalizableVault.moreActionsDeleteSheetSelect.localized,
                                type: FileActionType.delete)
    ]

