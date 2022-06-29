//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableCamera: String, LocalizableDelegate {
    
    case tabBar = "Camera_TabBar"
    
    case appBar = "Camera_AppBar"
    case tabTitlePhoto = "Camera_TabTitle_Photo"
    case tabTitleVideo = "Camera_TabTitle_Video"
    
    case encryptingProgressSheetTitle = "Camera_EncryptingProgress_SheetTitle"
    case encryptingProgressSheetExpl = "Camera_EncryptingProgress_SheetExpl"
    case encryptingProgressCancelSheetAction = "Camera_EncryptingProgress_Cancel_SheetAction"
    
    case cancelEncryptingSheetTitle = "Camera_CancelEncrypting_SheetTitle"
    case cancelEncryptingSheetExpl = "Camera_CancelEncrypting_SheetExpl"
    case cancelEncryptingDeleteSheetAction = "Camera_CancelEncrypting_Delete_SheetAction"
    case cancelEncryptingBackSheetAction = "Camera_CancelEncrypting_Back_SheetAction"
    
    case deniedCameraPermissionExpl = "Camera_DeniedCameraPermission_Expl"
    case deniedCameraPermissionActionSettings = "Camera_DeniedCameraPermission_Action_Settings"
    case deniedCameraPermissionActionCancel = "Camera_DeniedCameraPermission_Action_Cancel"
}
