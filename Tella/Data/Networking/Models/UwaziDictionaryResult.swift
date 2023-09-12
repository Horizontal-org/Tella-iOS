//
//  UwaziDictionaryResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziDictionaryResult: Codable {
    let rows: [UwaziDictionary]
}

// MARK: - Row
class UwaziDictionary: Codable {
    let id, name: String?
    var values: [SelectValue]? = []
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, values
        case v = "__v"
    }
}

// MARK: - Value
class SelectValue: Codable, Equatable, Hashable {
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


