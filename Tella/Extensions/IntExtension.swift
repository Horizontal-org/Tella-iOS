//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension Int64 {
    
    func getFormattedFileSize() -> String {
         let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: self)
    }
    
    
    
}
