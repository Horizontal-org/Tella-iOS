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
                        content: Localizable.Vault.manageFilesTakePhotoVideoSheetSelect,
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "mic-icon",
                        content: Localizable.Vault.manageFilesRecordAudioSheetSelect,
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "upload-icon",
                        content: Localizable.Vault.manageFilesImportFromDeviceSheetSelect,
                        type: ManageFileType.fromDevice),
    
    ListActionSheetItem(imageName: "new_folder-icon",
                        content: Localizable.Vault.manageFilesCreateNewFolderSheetSelect,
                        type: ManageFileType.folder)
]
}
