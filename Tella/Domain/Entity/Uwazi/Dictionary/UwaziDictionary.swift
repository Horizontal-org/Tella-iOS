//
//  UwaziDictionary.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziDictionary: DomainModel {
    let rows: [UwaziDictionaryRow]?
    init(rows: [UwaziDictionaryRow]?) {
        self.rows = rows
    }
}
