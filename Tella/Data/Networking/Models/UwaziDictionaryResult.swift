//
//  UwaziDictionaryResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziDictionaryResult: Codable {
    // TODO: Change this to a generic like for Codeable
    let rows: [UwaziDictionary]?
}

// MARK: - Row
struct UwaziDictionary: Codable {
    let id, name: String?
    let values: [SelectValue]?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, values
        case v = "__v"
    }
}

// MARK: - Value
struct SelectValue: Codable {
    let label, id: String?
    var translatedLabel: String? = ""
    let values : [NestedSelectValue]?
}
struct NestedSelectValue: Codable {
    let id : String?
    let label :String?
    var translatedLabel : String? = ""
}


