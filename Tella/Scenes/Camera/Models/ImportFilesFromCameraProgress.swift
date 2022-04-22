//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

struct ImportFilesFromCameraProgress : ImportFilesProgressProtocol {
    
    var progressType: ProgressType {
        return .percentage
    }
    
    var title: String {
        return Localizable.Camera.addFileProgressTitle
    }
    
    var progressMessage: String {
        return Localizable.Camera.addFileProgressComplete
    }

    var cancelTitle: String {
        return Localizable.Camera.cancelAddFileTitle
    }
    
    var cancelMessage: String {
        return Localizable.Camera.cancelAddFileMessage
    }
    
    var cancelButtonTitle: String {
        return Localizable.Camera.cancelAddFileButtonTitle
    }
}

