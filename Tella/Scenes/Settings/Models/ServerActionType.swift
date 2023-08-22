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
                        content: "Edit",
                        type: ServerActionType.edit),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: "Delete",
                        type: ServerActionType.delete)
]
}
var templateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: "Delete from this device",
                        type: TemplateActionType.delete)
    ]
}
var downloadTemplateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: "Create an entity",
                        type: DownloadedTemplateActionType.createEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: "Delete from this device",
                        type: DownloadedTemplateActionType.delete)
]
}
