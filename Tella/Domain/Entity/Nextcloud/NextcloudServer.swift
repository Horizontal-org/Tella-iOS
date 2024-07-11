//
//  NextcloudServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class NextcloudServer: WebServer, ServerProtocol {

    var userId: String?
    var rootFolder: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "c_user_id"
        case rootFolder = "c_root_folder"
    }
    
    init(serverURL: String?,
         username: String?,
         password: String?,
         userId: String? = nil ,
         rootFolder: String? = nil) {
        
        self.userId = userId
        self.rootFolder = rootFolder
        
        super.init(name: "Nextcloud", serverURL: serverURL, username: username, password: password, serverType: .nextcloud)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rootFolder = try container.decodeIfPresent(String.self, forKey: .rootFolder)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        
        self.serverType = .nextcloud
        self.allowMultiple = false
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rootFolder, forKey: .rootFolder)
        try container.encode(userId, forKey: .userId)
        try super.encode(to: encoder)
    }
}
