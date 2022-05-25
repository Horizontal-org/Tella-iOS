//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct ImportFilesFromCameraProgress : ImportFilesProgressProtocol {
    
    var progressType: ProgressType {
        return .percentage
    }
    
    var title: String {
        return Localizable.Camera.encryptingProgressSheetTitle
    }
    
    var progressMessage: String {
        return Localizable.Camera.encryptingProgressSheetExpl
    }
    
    var cancelImportButtonTitle: String {
        return Localizable.Camera.encryptingProgressCancelSheetAction
    }

    var cancelTitle: String {
        return Localizable.Camera.cancelEncryptingSheetTitle
    }
    
    var cancelMessage: String {
        return Localizable.Camera.cancelEncryptingSheetExpl
    }
    
    var exitCancelImportButtonTitle: String {
        return Localizable.Camera.cancelEncryptingBackSheetAction
    }
    
    var confirmCancelImportButtonTitle: String {
        return Localizable.Camera.cancelEncryptingDeleteSheetAction
    }
}

