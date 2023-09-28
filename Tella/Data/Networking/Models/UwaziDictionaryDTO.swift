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


