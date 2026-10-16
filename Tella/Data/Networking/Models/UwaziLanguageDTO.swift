//
//  UwaziLanguageResult.swift
//  Tella
//
//  Created by Robert Shrestha on 5/25/23.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

// MARK: - Welcome
struct UwaziLanguageDTO: Codable, DataModel {
    let rows: [UwaziLanguageRowDTO]?
    func toDomain() -> DomainModel? {
        let rows = rows?.compactMap{ $0.toDomain() as? UwaziLanguageRow}
        return UwaziLanguage(rows: rows)
    }
}
// MARK: - Row
struct UwaziLanguageRowDTO: Codable, DataModel {
    let id: String?
    let locale: String?
    let contexts: [UwaziLanguageContextDTO]?
    func toDomain() -> DomainModel? {
        let names = UwaziLanguageDisplayName.names(for: locale)
        return UwaziLanguageRow(id: id,
                                locale: locale,
                                languageName: names.native,
                                translatedLanguageName: names.translated)
    }
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
    }
}
// MARK: - Context
struct UwaziLanguageContextDTO: Codable, DataModel {
    let contextID, label: String?
    let values: [String: String]?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case contextID = "id"
        case label
        case values
        case id = "_id"
    }
    
    func toDomain() -> DomainModel? {
        return UwaziLanguageContext(contextID: contextID, label: label, id: id)
    }
}

enum UwaziLanguageDisplayName {
    static func names(for localeCode: String?) -> (native: String, translated: String) {
        let code = localeCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else { return ("", "") }

        let normalized = code.replacingOccurrences(of: "_", with: "-")
        let languageLocale = Locale(identifier: normalized)
        let appLocale = Locale(identifier: LanguageManager.shared.currentLanguage.code)

        let native = languageLocale.localizedString(forIdentifier: normalized) ?? code
        let translated = appLocale.localizedString(forIdentifier: normalized) ?? native

        return (
            capitalized(native, locale: languageLocale),
            capitalized(translated, locale: appLocale)
        )
    }

    private static func capitalized(_ value: String, locale: Locale) -> String {
        guard let first = value.first else { return value }
        return String(first).uppercased(with: locale) + value.dropFirst()
    }
}
