//
//  UwaziTranslation.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziTranslation: DomainModel {
    let rows: [UwaziTranslationRow]?
    init(rows: [UwaziTranslationRow]?) {
        self.rows = rows
    }
}
