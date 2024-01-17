//
//  UwaziServer.swift
//  Tella
//
//  Created by Gustavo on 13/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziServer : Server {
    var locale: String?
    var cookie: String?
    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         locale: String? = nil,
         serverType: ServerConnectionType? = .uwazi
        ) {
        self.locale = locale
        super.init(id: id, name: name, serverURL: serverURL, username: username, password: password, accessToken: accessToken, serverType: serverType)
        self.cookie = createCookie()
    }
    private func createCookie() -> String {
        let accessTokenValue = accessToken ?? ""
        let localeValue = locale ?? ""
        return "connect.sid=\(accessTokenValue);locale=\(localeValue)"
    }
}
