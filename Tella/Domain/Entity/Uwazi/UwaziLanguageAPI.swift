//
//  UwaziLanguageAPI.swift
//  Tella
//
//  Created by Robert Shrestha on 8/31/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziLanguageAPI: DomainModel {
    let id: String?
    let locale: String?
    let contexts: [UwaziLanguageContext]?
    let languageName: String
    
    init(id: String?,
         locale: String?,
         contexts: [UwaziLanguageContext]?,
         languageName: String) {

        self.id = id
        self.locale = locale
        self.contexts = contexts
        self.languageName = languageName

    }
}
