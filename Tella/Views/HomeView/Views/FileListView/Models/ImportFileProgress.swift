//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct  ImportFilesProgress : ImportFilesProgressProtocol {

    var progressType: ProgressType {
        return .number
    }
    
    var title: String {
        return LocalizableHome.importProgressTitle.localized
    }
    
    var progressMessage: String {
        return LocalizableHome.importProgressFileImported.localized
    }
    
    var cancelTitle: String {
        return LocalizableHome.cancelImportFileTitle.localized
    }
    
    var cancelMessage: String {
        return LocalizableHome.cancelImportFileMessage.localized
    }
    
    var cancelButtonTitle: String {
        return LocalizableHome.cancelImportFileCancelImport.localized
    }
}
