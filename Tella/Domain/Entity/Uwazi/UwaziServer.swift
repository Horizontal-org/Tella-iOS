//
//  UwaziServer.swift
//  Tella
//
//  Created by Gustavo on 13/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziServer : WebServer {
    var locale: String?
    var cookie: String?
    var accessToken: String?

    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         locale: String? = nil,
         serverType: ServerConnectionType? = .uwazi) {
        
        super.init(id: id,
                   name: name,
                   serverURL: serverURL, 
                   username: username,
                   password: password,
                   serverType: serverType)
        self.locale = locale
        self.accessToken = accessToken
        self.cookie = createCookie()
        self.allowMultiple = false
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    private func createCookie() -> String {
        let accessTokenValue = accessToken ?? ""
        let localeValue = locale ?? ""
        return "connect.sid=\(accessTokenValue);locale=\(localeValue)"
    }
}
