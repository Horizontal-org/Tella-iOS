//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum ServerConnectionType: Int, Codable {
    case tella
    case uwazi
    case gDrive
}

extension ServerConnectionType {
    var successConnectionButtonContent: String {
        switch self {
        case .gDrive:
            return "GO TO GOOGLE DRIVE"
        case.tella:
            return "GO TO REPORTS"
        default:
            return ""
        }
    }
    
    var serverTitle: String {
        switch self {
        case .gDrive:
            "GOOGLE DRIVE"
        default:
            ""
        }
    }
}
