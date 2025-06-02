//
//  UwaziProperty.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class Property: DomainModel, Codable{
    let content, id, label, type: String?
    let propertyRequired: Bool?
    let name: String?
    var translatedLabel : String? = ""
    let filter, showInCard: Bool?
    let relationType: String?
    var values : [SelectValue]? = nil

    init(content: String?, id: String?, label: String?, type: String?, propertyRequired: Bool?, name: String?, translatedLabel: String?, filter: Bool?, showInCard: Bool?, relationType: String?, values: [SelectValue]?) {
        self.content = content
        self.id = id
        self.label = label
        self.type = type
        self.propertyRequired = propertyRequired
        self.name = name
        self.translatedLabel = translatedLabel
        self.filter = filter
        self.showInCard = showInCard
        self.relationType = relationType
        self.values = values
    }
}
