//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


enum AddPhotoVideoType: ActionType {
    case photoLibrary
    case document
}

var AddPhotoVideoItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "photo-library",
                        content: Localizable.Home.photoLibrary,
                        type: AddPhotoVideoType.photoLibrary),
    
    ListActionSheetItem(imageName: "document",
                        content: Localizable.Home.document,
                        type: AddPhotoVideoType.document)]
}
