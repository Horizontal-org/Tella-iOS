//
//  UwaziLanguageAPI.swift
//  Tella
//
//  Created by Robert Shrestha on 8/31/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziLanguage: DomainModel {
    let rows: [UwaziLanguageRow]?
    init(rows: [UwaziLanguageRow]?) {
        self.rows = rows
    }
}
