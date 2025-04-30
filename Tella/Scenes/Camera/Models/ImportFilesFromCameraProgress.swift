//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct ImportFilesFromCameraProgress : ImportFilesProgressProtocol {
    
    var progressType: ProgressType {
        return .percentage
    }
    
    var title: String {
        return LocalizableCamera.encryptingProgressSheetTitle.localized
    }
    
    var progressMessage: String {
        return LocalizableCamera.encryptingProgressSheetExpl.localized
    }
    
    var cancelImportButtonTitle: String {
        return LocalizableCamera.encryptingProgressCancelSheetAction.localized
    }

    var cancelTitle: String {
        return LocalizableCamera.cancelEncryptingSheetTitle.localized
    }
    
    var cancelMessage: String {
        return LocalizableCamera.cancelEncryptingSheetExpl.localized
    }
    
    var exitCancelImportButtonTitle: String {
        return LocalizableCamera.cancelEncryptingBackSheetAction.localized
    }
    
    var confirmCancelImportButtonTitle: String {
        return LocalizableCamera.cancelEncryptingDeleteSheetAction.localized
    }
}

