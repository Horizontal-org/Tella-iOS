//
//  GDriveServer.swift
//  Tella
//
//  Created by gus valbuena on 5/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveServer: Server {
    var rootFolder: String?

    enum CodingKeys: String, CodingKey {
        case rootFolder = "c_root_folder"
    }

    init(id: Int? = nil,
         name: String? = LocalizableGDrive.gDriveAppBar.localized,
         rootFolder: String,
         serverType: ServerConnectionType? = .gDrive) {
        
        self.rootFolder = rootFolder
        super.init(id: id,
                   name: name,
                   serverType: serverType,
                   allowMultipleConnections: false)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rootFolder = try container.decode(String?.self, forKey: .rootFolder)
        try super.init(from: decoder)
        self.serverType = .gDrive
        self.allowMultiple = false
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rootFolder, forKey: .rootFolder)
        try super.encode(to: encoder)
    }
}
