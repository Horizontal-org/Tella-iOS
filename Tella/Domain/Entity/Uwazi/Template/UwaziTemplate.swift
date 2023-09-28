//
//  UwaziTemplate.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziTemplate: DomainModel {
    let rows: [UwaziTemplateRow]?
    init(rows: [UwaziTemplateRow]?) {
        self.rows = rows
    }
}
