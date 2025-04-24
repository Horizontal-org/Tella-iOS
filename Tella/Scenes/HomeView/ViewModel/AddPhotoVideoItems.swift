//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation


enum AddPhotoVideoType: ActionType {
    case photoLibrary
    case document
}

var AddPhotoVideoItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "photo-library",
                        content: LocalizableVault.manageFilesPhotoLibrarySheetSelect.localized,
                        type: AddPhotoVideoType.photoLibrary),
    
    ListActionSheetItem(imageName: "document",
                        content: LocalizableVault.manageFilesDocumentSheetSelect.localized,
                        type: AddPhotoVideoType.document)]
}
