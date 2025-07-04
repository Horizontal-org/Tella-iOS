//
//  ResourceActionType.swift
//  Tella
//
//  Created by gus valbuena on 2/19/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


enum ResourceActionType: ActionType {
    case delete
    case viewResource
}

var ResourceActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "view-icon",
                        content: LocalizableResources.resourcesDownloadViewSheetSelect.localized,
                        type: ResourceActionType.viewResource),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: LocalizableResources.resourcesDownloadedRemoveSheetSelect.localized,
                        type: ResourceActionType.delete)
    ]
}
