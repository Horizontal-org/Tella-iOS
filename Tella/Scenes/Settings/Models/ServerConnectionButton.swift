//
//  ServerConnectionButton.swift
//  Tella
//
//  Created by gus valbuena on 5/28/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct ServerConnectionButton {
    let title: String
    let type: ServerConnectionType
}

let serverConnections: [ServerConnectionButton] = [
    ServerConnectionButton(title: LocalizableSettings.settServerTellaWeb.localized, type: .tella),
    ServerConnectionButton(title: LocalizableSettings.settServerUwazi.localized, type: .uwazi),
    ServerConnectionButton(title: LocalizableSettings.settServerGDrive.localized, type: .gDrive),
    ServerConnectionButton(title: LocalizableSettings.settServerNextCloud.localized, type: .nextcloud),
    ServerConnectionButton(title: LocalizableSettings.settServerDropbox.localized, type: .dropbox)
]
