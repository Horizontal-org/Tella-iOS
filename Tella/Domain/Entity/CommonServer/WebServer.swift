//
//  WebServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class WebServer: Server {
    
    var url: String?
    var username: String?
    var password: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "c_url"
        case username = "c_username"
        case password = "c_password"
    }
    
    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         serverType: ServerConnectionType? = nil) {
        self.url = serverURL
        self.username = username
        self.password = password
        
        super.init(id: id,
                   name: name,
                   serverType: serverType)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try super.encode(to: encoder)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        try super.init(from: decoder)
    }
}


