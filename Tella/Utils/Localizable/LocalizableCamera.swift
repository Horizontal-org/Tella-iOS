//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    
    case deniedCameraPermissionExpl1 = "Camera_DeniedCameraPermission_Expl1"
    case deniedCameraPermissionExpl2 = "Camera_DeniedCameraPermission_Expl2"
    case deniedCameraPermissionExpl3 = "Camera_DeniedCameraPermission_Expl3"
    case deniedCameraPermissionExpl4 = "Camera_DeniedCameraPermission_Expl4"
    case deniedCameraPermissionExpl5 = "Camera_DeniedCameraPermission_Expl5"
    case deniedCameraPermissionActionSettings = "Camera_DeniedCameraPermission_Action_Settings"
    case deniedCameraPermissionActionCancel = "Camera_DeniedCameraPermission_Action_Cancel"
}
