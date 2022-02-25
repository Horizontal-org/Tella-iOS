//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct ImportFilesFromCameraProgress : ImportFilesProgressProtocol {
    
    var progressType: ProgressType {
        return .percentage
    }
    
    var title: String {
        return LocalizableCamera.addFileProgressTitle.localized
    }
    
    var progressMessage: String {
        return LocalizableCamera.addFileProgressComplete.localized
    }

    var cancelTitle: String {
        return LocalizableCamera.cancelAddFileTitle.localized
    }
    
    var cancelMessage: String {
        return LocalizableCamera.cancelAddFileMessage.localized
    }
    
    var cancelButtonTitle: String {
        return LocalizableCamera.cancelAddFileButtonTitle.localized
    }
}

