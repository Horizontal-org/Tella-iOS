//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


enum ServerActionType: ActionType {
    case edit
    case delete
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
