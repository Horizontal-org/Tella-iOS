//
//  ServerDeleteMessage.swift
//  Tella
//
//  Created by Robert Shrestha on 9/7/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

// TODO: Maybe use another class name
struct DeleteServerTexts {
    var titleText: String = ""
    var messageText: String = ""
    let cancelText = "CANCEL"
    let actionText = "DELETE"
    init(server: Server) {
        if server.serverType == .tella {
            titleText = "Delete \(server.name ?? "") server?"
            messageText = "f you delete this server, all draft and submitted forms will be deleted from your device."
        } else if server.serverType == .uwazi {
            titleText = "Delete \"\(server.name ?? "")\" connection?"
            messageText = "If you delete this server, all draft and submitted entities will be deleted from your device. Delete anyway?"
        } else {}
    }
}
