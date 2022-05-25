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
                        content: Localizable.Home.shareFile,
                        type: FileActionType.share)
]

var secondFileActionItems : [ListActionSheetItem] {
    
    return [ListActionSheetItem(imageName: "move-icon",
                                content: Localizable.Home.moveFile,
                                type: FileActionType.move),
            
            ListActionSheetItem(imageName: "edit-icon",
                                content: Localizable.Home.renameFile,
                                type: FileActionType.rename),
            
            ListActionSheetItem(imageName: "save-icon",
                                content: Localizable.Home.saveFile,
                                type: FileActionType.save),
            
            ListActionSheetItem(imageName: "info-icon",
                                content: Localizable.Home.fileInformation,
                                type: FileActionType.info),
            
            ListActionSheetItem(imageName: "delete-icon",
                                content: Localizable.Home.deleteFile,
                                type: FileActionType.delete)
    ]
}
