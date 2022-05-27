//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct  ImportFilesProgress : ImportFilesProgressProtocol {
    

    var progressType: ProgressType {
        return .number
    }
    
    var title: String {
        return Localizable.Vault.importProgressSheetTitle
    }
    
    var progressMessage: String {
        return Localizable.Vault.importProgressSheetExpl
    }
    
    var cancelImportButtonTitle: String {
        return Localizable.Vault.importProgressCancelSheetAction
    }

    var cancelTitle: String {
        return Localizable.Vault.cancelImportFileSheetTitle
    }
    
    var cancelMessage: String {
        return Localizable.Vault.cancelImportFileSheetExpl
    }
    
    var exitCancelImportButtonTitle: String {
        return Localizable.Vault.cancelImportFileBackSheetAction
    }

    var confirmCancelImportButtonTitle: String {
        return Localizable.Vault.cancelImportFileCancelImportSheetAction
    }
}
