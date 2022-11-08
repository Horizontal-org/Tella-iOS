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
                        content: "Edit",
                        type: ServerActionType.edit),
    ListActionSheetItem(imageName: "delete-icon-white",
                        content: "Delete",
                        type: ServerActionType.delete)
]
}
