//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum OpenXmlFormats : String {
    
    case word = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case presentation = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case sheet = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    
    var fileExtension: String {
        
        switch self {
            
        case .word :
            return "docx"
            
        case .presentation :
            return "pptx"
            
        case .sheet :
            return "xlsx"
            
        }
    }
}
