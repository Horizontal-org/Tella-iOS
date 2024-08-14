//
//  NextcloudServerParameters.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextcloudServerParameters {
    
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
    
    
    init(userId: String?,
         url: String?,
         username: String?,
         password: String?) throws {
        guard
            let username = username,
            let userId = userId,
            let password = password,
            let url = url
        else {
            throw RuntimeError(LocalizableCommon.commonError.localized)
            
        }
        self.userId = userId
        self.url = url
        self.username = username
        self.password = password
    }
}
