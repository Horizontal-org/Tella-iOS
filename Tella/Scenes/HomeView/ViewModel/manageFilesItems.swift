//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


enum ManageFileType: ActionType {
    case camera
    case recorder
    case fromDevice
    case folder
}

var manageFilesItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "camera-icon",
                        content: "Take photo/video",
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "mic-icon",
                        content: "Record audio",
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "upload-icon",
                        content: "Import from device",
                        type: ManageFileType.fromDevice),
    
    ListActionSheetItem(imageName: "new_folder-icon",
                        content: "Create a new folder",
                        type: ManageFileType.folder)
]
}
