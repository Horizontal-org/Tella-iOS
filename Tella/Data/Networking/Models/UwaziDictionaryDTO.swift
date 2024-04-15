//
//  UwaziDictionaryResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziDictionaryDTO: Codable {
    let rows: [UwaziDictionaryRowDTO]?
}

class UwaziDictionaryRowDTO: Codable {
    let id, name: String?
    var values: [SelectValue]? = []
    let version: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, values
        case version = "__v"
    }
}

class SelectValue: Codable, Equatable, Hashable, Identifiable {
    var label, id: String?
    var translatedLabel: String? = ""
    var values : [NestedSelectValue]? = []
    
    init(label: String, id: String?, translatedLabel: String?, values: [NestedSelectValue]) {
        self.label = label
        self.id = id
        self.translatedLabel = translatedLabel
        self.values = values
    }

    static func == (lhs: SelectValue, rhs: SelectValue) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
class NestedSelectValue: Codable {
    var id : String?
    var label :String?
    var translatedLabel : String? = ""
}


