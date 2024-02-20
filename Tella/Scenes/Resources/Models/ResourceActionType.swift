//
//  ResourceActionType.swift
//  Tella
//
//  Created by gus valbuena on 2/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


enum ResourceActionType: ActionType {
    case delete
    case viewResource
}

var ResourceActionItems : [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "edit-icon",
                        content: "View",
                        type: ResourceActionType.viewResource),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: "Remove from downloads",
                        type: ResourceActionType.delete)
    ]
}
