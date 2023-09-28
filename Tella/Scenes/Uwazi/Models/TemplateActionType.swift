//
//  TemplateActionType.swift
//  Tella
//
//  Created by Gustavo on 22/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum TemplateActionType: ActionType {
    case delete
}
enum DownloadedTemplateActionType: ActionType {
    case delete
    case createEntity
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
