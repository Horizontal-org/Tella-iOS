//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


enum ServerActionType: ActionType {
    case edit
    case delete
}

enum TemplateActionType: ActionType {
    case delete
}
enum DownloadedTemplateActionType: ActionType {
    case delete
    case createEntity
}


var serverActionItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.uwaziServerEdit.localized,
                        type: ServerActionType.edit),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.uwaziServerDelete.localized,
                        type: ServerActionType.delete)
]
}
var templateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.uwaziDeleteEntitySheetExpl.localized,
                        type: TemplateActionType.delete)
    ]
}
var downloadTemplateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.uwaziCreateEntitySheetExpl.localized,
                        type: DownloadedTemplateActionType.createEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.uwaziDeleteEntitySheetExpl.localized,
                        type: DownloadedTemplateActionType.delete)
]
}
