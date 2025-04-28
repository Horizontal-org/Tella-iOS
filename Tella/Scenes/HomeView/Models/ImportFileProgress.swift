//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct  ImportFilesProgress : ImportFilesProgressProtocol {
    
    

    var progressType: ProgressType {
        return .number
    }
    
    var title: String {
        return LocalizableVault.importProgressSheetTitle.localized
    }
    
    var progressMessage: String {
        return LocalizableVault.importProgressSheetExpl.localized
    }
    
    var cancelImportButtonTitle: String {
        return LocalizableVault.importProgressCancelSheetAction.localized
    }

    var cancelTitle: String {
        return LocalizableVault.cancelImportFileSheetTitle.localized
    }
    
    var cancelMessage: String {
        return LocalizableVault.cancelImportFileSheetExpl.localized
    }
    
    var exitCancelImportButtonTitle: String {
        return LocalizableVault.cancelImportFileBackSheetAction.localized
    }

    var confirmCancelImportButtonTitle: String {
        return LocalizableVault.cancelImportFileCancelImportSheetAction.localized
    }
}
