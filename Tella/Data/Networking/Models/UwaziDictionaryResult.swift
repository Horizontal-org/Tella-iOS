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
class SelectValue: Codable {
    var label, id: String?
    var translatedLabel: String? = ""
    var values : [NestedSelectValue]? = []
}
class NestedSelectValue: Codable {
    var id : String?
    var label :String?
    var translatedLabel : String? = ""
}


