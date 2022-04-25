//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct  ImportFilesProgress : ImportFilesProgressProtocol {

    var progressType: ProgressType {
        return .number
    }
    
    var title: String {
        return Localizable.Home.importProgressTitle
    }
    
    var progressMessage: String {
        return Localizable.Home.importProgressFileImported
    }
    
    var cancelTitle: String {
        return Localizable.Home.cancelImportFileTitle
    }
    
    var cancelMessage: String {
        return Localizable.Home.cancelImportFileMessage
    }
    
    var cancelButtonTitle: String {
        return Localizable.Home.cancelImportFileCancelImport
    }
}
