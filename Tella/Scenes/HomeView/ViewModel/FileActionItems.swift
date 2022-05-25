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
                        content: Localizable.Vault.moreActionsShareSheetSelect,
                        type: FileActionType.share)
]

var secondFileActionItems : [ListActionSheetItem] {
    
    return [ListActionSheetItem(imageName: "move-icon",
                                content: Localizable.Vault.moreActionsMoveSheetSelect,
                                type: FileActionType.move),
            
            ListActionSheetItem(imageName: "edit-icon",
                                content: Localizable.Vault.moreActionsRenameSheetSelect,
                                type: FileActionType.rename),
            
            ListActionSheetItem(imageName: "save-icon",
                                content: Localizable.Vault.moreActionsSaveSheetSelect,
                                type: FileActionType.save),
            
            ListActionSheetItem(imageName: "info-icon",
                                content: Localizable.Vault.moreActionsFileInformationSheetSelect,
                                type: FileActionType.info),
            
            ListActionSheetItem(imageName: "delete-icon",
                                content: Localizable.Vault.moreActionsDeleteSheetSelect,
                                type: FileActionType.delete)
    ]
}
