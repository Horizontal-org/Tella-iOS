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

var uwaziDraftActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.editDraft.localized,
                        type: UwaziActionType.createEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.deleteDraft.localized,
                        type: UwaziActionType.delete)
    ]
}

var uwaziOutboxActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.viewSheetSelect.localized,
                        type: UwaziActionType.viewOutboxEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.deleteSheetSelect.localized,
                        type: UwaziActionType.delete)
    ]
}

var uwaziSubmittedActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: LocalizableUwazi.viewSheetSelect.localized,
                        type: UwaziActionType.viewSubmittedEntity),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableUwazi.deleteSheetSelect.localized,
                        type: UwaziActionType.delete)
    ]
}
