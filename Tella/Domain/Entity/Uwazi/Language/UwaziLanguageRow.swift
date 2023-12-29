//
//  UwaziLanguageRow.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziLanguageRow: DomainModel, Hashable {
    let id: String?
    let locale: String?
    let languageName: String

    init(id: String?,
         locale: String?,
         languageName: String) {
        self.id = id
        self.locale = locale
        self.languageName = languageName

    }
    static func == (lhs: UwaziLanguageRow, rhs: UwaziLanguageRow) -> Bool {
        lhs.locale == rhs.locale
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(locale)
    }
}
