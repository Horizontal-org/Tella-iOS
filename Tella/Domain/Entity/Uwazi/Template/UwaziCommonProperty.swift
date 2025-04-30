//
//  UwaziCommonProperty.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class CommonProperty: DomainModel, Codable {
    let id, label, name: String?
    let isCommonProperty: Bool?
    let type: String?
    var translatedLabel: String? = ""
    let prioritySorting, generatedID: Bool?

    init(id: String?, label: String?, name: String?, isCommonProperty: Bool?, type: String?, translatedLabel: String?, prioritySorting: Bool?, generatedID: Bool?) {
        self.id = id
        self.label = label
        self.name = name
        self.isCommonProperty = isCommonProperty
        self.type = type
        self.translatedLabel = translatedLabel
        self.prioritySorting = prioritySorting
        self.generatedID = generatedID
    }
}
