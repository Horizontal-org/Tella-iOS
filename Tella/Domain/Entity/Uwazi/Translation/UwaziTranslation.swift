//
//  UwaziTranslation.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziTranslation: DomainModel {
    let rows: [UwaziTranslationRow]?
    init(rows: [UwaziTranslationRow]?) {
        self.rows = rows
    }
}
