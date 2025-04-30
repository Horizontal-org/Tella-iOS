//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

import MobileCoreServices

class MIMEType {
    
    static let unknown = "application/octet-stream"
    
    static func mime(for fileExtension: String) -> String {
        
        guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) else {
            return MIMEType.unknown
        }
        
        guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI.takeUnretainedValue(), kUTTagClassMIMEType) else {
            return MIMEType.unknown
        }
        
        return String(mimeUTI.takeUnretainedValue())
    }
    
    
}
