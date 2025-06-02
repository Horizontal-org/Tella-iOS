//
//  UwaziSetting.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziSetting: DomainModel {
    let id: String?
    let allowedPublicTemplates: [String]
    let mapAPIKey: String?
    init(id: String?, allowedPublicTemplates: [String], mapAPIKey: String?) {
        self.id = id
        self.allowedPublicTemplates = allowedPublicTemplates
        self.mapAPIKey = mapAPIKey
    }
}
