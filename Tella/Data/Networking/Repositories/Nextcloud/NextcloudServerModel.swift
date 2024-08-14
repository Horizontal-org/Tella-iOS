//
//  NextcloudServerParameters.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextcloudServerModel {
    
    var userId: String
    var rootFolder: String?
    var url: String
    var username: String
    var password: String

    init(server:NextcloudServer?) throws {
        guard
            let username = server?.username,
            let userId = server?.userId,
            let password = server?.password,
            let url = server?.url
        else {
            throw RuntimeError(LocalizableCommon.commonError.localized)
            
        }
        let rootFolder = server?.rootFolder
        
        self.userId = userId
        self.rootFolder = rootFolder
        self.url = url
        self.username = username
        self.password = password
    }
}
