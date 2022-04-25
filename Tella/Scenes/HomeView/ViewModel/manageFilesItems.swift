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
                        content: Localizable.Home.takePhotoVideo,
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "mic-icon",
                        content: Localizable.Home.recordAudio,
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "upload-icon",
                        content: Localizable.Home.importFromDevice,
                        type: ManageFileType.fromDevice),
    
    ListActionSheetItem(imageName: "new_folder-icon",
                        content: Localizable.Home.createNewFolder,
                        type: ManageFileType.folder)
]
}
