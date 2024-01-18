//
//  UwaziTranslationRow.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziTranslationRow: DomainModel {
    let id, locale: String?
    let contexts: [UwaziTranslationContext]
    init(id: String?,
         locale: String?,
         contexts: [UwaziTranslationContext]) {
        self.id = id
        self.locale = locale
        self.contexts = contexts
    }
}
