//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

import MobileCoreServices
import UniformTypeIdentifiers

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
