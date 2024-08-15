//
//  ServerDeleteMessage.swift
//  Tella
//
//  Created by Robert Shrestha on 9/7/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

// TODO: Maybe use another class name
enum DeleteServerTexts {
    case tella(String)
    case uwazi(String)
    case gDrive(String)
    case unknown

    var titleText: String {
        switch self {
        case .tella(let name):
            return String(format: LocalizableSettings.settServerDeleteTellaConnectionTitle.localized, name)
        case .uwazi(let name), .gDrive(let name):
            return String(format: LocalizableSettings.settServerDeleteConnectionTitle.localized, name)
        case .unknown:
            return ""
        }
    }
    
    var messageText: String {
        switch self {
        case .uwazi:
            return LocalizableSettings.settServerDeleteUwaziConnectionMessage.localized
        case .unknown:
            return ""
        default:
            return LocalizableSettings.settServerDeleteConnectionMessage.localized
        }
    }

    var cancelText: String {
        return LocalizableSettings.settServerCancelSheetAction.localized
    }
    
    var actionText: String {
        return LocalizableSettings.settServerDeleteSheetAction.localized
    }
}

extension DeleteServerTexts {
    init(server: Server) {
        let serverName = server.name ?? ""
        switch server.serverType {
        case .tella:
            self = .tella(serverName)
        case .uwazi:
            self = .uwazi(serverName)
        case .gDrive:
            self = .gDrive(serverName)
        default:
            self = .unknown
        }
    }
}
