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
            return LocalizableSettings.GDriveSuccessMessage.localized
        case.tella:
            return LocalizableSettings.settServerReportsSuccessMessage.localized
        default:
            return ""
        }
    }
    
    var serverTitle: String {
        switch self {
        case .gDrive:
            LocalizableSettings.settServerGDrive.localized
        default:
            ""
        }
    }
}
