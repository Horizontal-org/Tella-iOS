//
//  UwaziLanguageContext.swift
//  Tella
//
//  Created by Robert Shrestha on 9/5/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziLanguageContext: DomainModel {
    let contextID, label: String?
    let id: String?

    init(contextID: String? = nil,
         label: String? = nil,
         id: String? = nil) {
        self.contextID = contextID
        self.label = label
        self.id = id

    }
}
