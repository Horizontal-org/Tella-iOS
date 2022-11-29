//
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


var AddFileToDraftItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "report.camera-filled",
                        content: "Take photo or video with camera",
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "report.mic-filled",
                        content: "Record audio",
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "report.gallery",
                        content: "Select from Tella files",
                        type: ManageFileType.tellaFile),
    ListActionSheetItem(imageName: "report.phone",
                        content: "Select from your device",
                        type: ManageFileType.fromDevice)
]
}

