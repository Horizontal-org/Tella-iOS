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
    case tellaFile
}

var manageFilesItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "camera-icon",
                        content: LocalizableVault.manageFilesTakePhotoVideoSheetSelect.localized,
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "mic-icon",
                        content: LocalizableVault.manageFilesRecordAudioSheetSelect.localized,
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "upload-icon",
                        content: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized,
                        type: ManageFileType.fromDevice),
    
    ListActionSheetItem(imageName: "new_folder-icon",
                        content: LocalizableVault.manageFilesCreateNewFolderSheetSelect.localized,
                        type: ManageFileType.folder)
]
}
