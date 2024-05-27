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
            return "Delete \(name) server?"
        case .uwazi(let name):
            return "Delete \"\(name)\" connection?"
        case .gDrive(let name):
            return "Delete \"\(name)\" connection?"
        case .unknown:
            return ""
        }
    }
    
    var messageText: String {
        switch self {
        case .tella:
            return "if you delete this server, all draft and submitted forms will be deleted from your device."
        case .uwazi:
            return "If you delete this server, all draft and submitted entities will be deleted from your device. Delete anyway?"
        case .gDrive:
            return "If you delete this server, all draft and submitted reports will be deleted from your device."
        case .unknown:
            return ""
        }
    }

    var cancelText: String {
        return "CANCEL"
    }
    
    var actionText: String {
        return "Delete"
    }
}

extension DeleteServerTexts {
    init(server: Server) {
        switch server.serverType {
        case .tella:
            self = .tella(server.name ?? "")
        case .uwazi:
            self = .uwazi(server.name ?? "")
        case .gDrive:
            self = .gDrive(server.name ?? "")
        default:
            self = .unknown
        }
    }
}
