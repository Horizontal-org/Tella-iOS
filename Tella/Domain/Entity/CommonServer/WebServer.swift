//
//  WebServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class WebServer: Server {
    
    var url: String?
    var username: String?
    var password: String?
    var accessToken: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "c_url"
        case username = "c_username"
        case password = "c_password"
        case accessToken = "c_access_token"
    }
    
    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         serverType: ServerConnectionType? = nil) {
        self.url = serverURL
        self.username = username
        self.password = password
        self.accessToken = accessToken
        
        super.init(id: id,
                   name: name,
                   serverType: serverType)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}


