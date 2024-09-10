//
//  DropboxData.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaData {
    func getDropboxServers() -> [Server] {
        self.database.getDropboxServers()
    }
}
