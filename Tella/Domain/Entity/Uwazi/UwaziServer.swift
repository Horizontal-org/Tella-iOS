//
//  UwaziServer.swift
//  Tella
//
//  Created by Gustavo on 13/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziServer : Hashable {
    var id : Int?
    var name : String?
    var url : String?
    var username : String?
    var password : String?
    var accessToken : String?
    var locale: String?
    var serverType: ServerConnectionType?
    var cookie: String?
    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         locale: String? = nil,
         serverType: ServerConnectionType? = nil
        ) {
        self.id = id
        self.name = name
        self.url = serverURL
        self.username = username
        self.password = password
        self.accessToken = accessToken
        self.serverType = serverType
        self.locale = locale
        self.cookie = createCookie()
    }
    
    init() {
        self.cookie = createCookie()
    }
    
    static func == (lhs: UwaziServer, rhs: UwaziServer) -> Bool {
        lhs.id  == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id.hashValue)
    }
    
    private func createCookie() -> String {
        let accessTokenValue = accessToken ?? ""
        let localeValue = locale ?? ""
        return "connect.sid=\(accessTokenValue);locale=\(localeValue)"
    }
}
