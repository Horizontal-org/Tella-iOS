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

enum UwaziActionType: ActionType {
    case delete
    case createEntity
    case viewOutboxEntity
    case viewSubmittedEntity
}

var templateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.uwaziDeleteFromDevice.localized,
                        type: TemplateActionType.delete)
    ]
}

var downloadTemplateActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.uwaziCreateEntitySheetExpl.localized,
                        type: UwaziActionType.createEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.uwaziDeleteTemplate.localized,
                        type: UwaziActionType.delete)
    ]
}
