//
//  UwaziTemplate.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziTemplate: DomainModel {
    let rows: [UwaziTemplateRow]?
    init(rows: [UwaziTemplateRow]?) {
        self.rows = rows
    }
}
