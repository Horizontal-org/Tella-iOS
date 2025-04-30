//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum ServerConnectionType: Codable {
    case tella
    case uwazi
    case gDrive
    case nextcloud
    case dropbox

}

extension ServerConnectionType {
    var successConnectionButtonContent: String {
        switch self {
        case .gDrive:
            return LocalizableSettings.gDriveSuccessMessage.localized
        case.tella:
            return LocalizableSettings.settServerReportsSuccessMessage.localized
        case .nextcloud:
            return LocalizableSettings.nextcloudSuccessMessage.localized
        case.dropbox:
            return LocalizableSettings.settServerDropboxSuccessMessage.localized
        default:
            return ""
        }
    }
    
    var serverTitle: String {
        switch self {
        case .gDrive:
            LocalizableSettings.settServerGDrive.localized
        case .uwazi:
            LocalizableSettings.settServerUwazi.localized
        case .nextcloud:
            LocalizableSettings.settServerNextCloud.localized
        case .dropbox:
            LocalizableSettings.settServerDropbox.localized
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
        case .dropbox:
            return "dropbox.icon"
        }
    }
}
