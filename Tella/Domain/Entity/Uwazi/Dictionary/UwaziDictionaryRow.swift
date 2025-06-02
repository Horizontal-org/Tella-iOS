//
//  UwaziDictionaryRow.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziDictionaryRow: DomainModel {
    let id, name: String?
    var values: [SelectValue]? = []
    init(id: String?, name: String?, values: [SelectValue]?) {
        self.id = id
        self.name = name
        self.values = values
    }
}
