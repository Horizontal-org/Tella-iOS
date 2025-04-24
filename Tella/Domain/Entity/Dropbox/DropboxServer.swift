//
//  DropboxServer.swift
//  Tella
//
//  Created by gus valbuena on 9/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class DropboxServer: Server {
    init(id: Int? = nil, name: String? = LocalizableDropbox.dropboxAppBar.localized, serverType: ServerConnectionType? = .dropbox) {
        super.init(id: id, name: name, serverType: serverType, allowMultipleConnections: false)
    }
    
    required init(from decoder: Decoder) throws {
        _ = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        self.serverType = .dropbox
        self.allowMultiple = false
    }
    
    override func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
    }
}
