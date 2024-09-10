//
//  DropboxServer.swift
//  Tella
//
//  Created by gus valbuena on 9/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxServer: Server {
    init(id: Int? = nil, name: String? = "Dropbox", serverType: ServerConnectionType? = .dropbox) {
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
