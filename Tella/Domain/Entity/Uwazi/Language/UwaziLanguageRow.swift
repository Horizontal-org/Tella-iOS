//
//  UwaziLanguageRow.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziLanguageRow: DomainModel, Hashable {
    let id: String?
    let locale: String?
    let languageName: String
    let translatedLanguageName: String

    init(id: String?,
         locale: String?,
         languageName: String,
         translatedLanguageName: String) {
        self.id = id
        self.locale = locale
        self.languageName = languageName
        self.translatedLanguageName = translatedLanguageName
    }
    static func == (lhs: UwaziLanguageRow, rhs: UwaziLanguageRow) -> Bool {
        lhs.locale == rhs.locale
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(locale)
    }
}
