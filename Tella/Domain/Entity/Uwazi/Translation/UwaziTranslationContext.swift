//
//  TranslationContext.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class UwaziTranslationContext: DomainModel {
    let contextID: String?
    let values: [String: String]?
    let id: String?
    init(contextID: String?,
         values: [String : String]?,
         id: String?) {
        self.contextID = contextID
        self.values = values
        self.id = id
    }
}
