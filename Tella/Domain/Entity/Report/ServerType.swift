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
    
    var connectionName: String {
        switch self {
        case .gDrive:
            LocalizableLock.onboardingConnectionsGDrive.localized
        case .uwazi:
            LocalizableLock.onboardingConnectionsUwazi.localized
        case .nextcloud:
            LocalizableLock.onboardingConnectionsNextcloud.localized
        case .dropbox:
            LocalizableLock.onboardingConnectionsDropbox.localized
        case .tella:
            LocalizableLock.onboardingConnectionsTellaWeb.localized
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
