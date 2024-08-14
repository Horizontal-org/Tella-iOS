//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum ServerConnectionType: Codable {
    case tella
    case uwazi
    case gDrive
    case nextcloud

}

extension ServerConnectionType {
    var successConnectionButtonContent: String {
        switch self {
        case .gDrive:
            return LocalizableSettings.GDriveSuccessMessage.localized
        case.tella:
            return LocalizableSettings.settServerReportsSuccessMessage.localized
        case .nextcloud:
            return LocalizableSettings.nextcloudSuccessMessage.localized
        default:
            return ""
        }
    }
    
    var serverTitle: String {
        switch self {
        case .gDrive:
            LocalizableSettings.settServerGDrive.localized
        case .nextcloud:
            LocalizableSettings.settServerNextCloud.localized
        default:
            ""
        }
    }
    
    var emptyIcon: String {
        switch self {
        case .gDrive:
            return "drive.empty"
        case .uwazi:
            return "uwazi.empty"
        case.tella:
            return "reports.report"
        case .nextcloud:
            return "nextcloud.icon"
        }
    }
}
