//
//  OuisyncModels.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

struct OuisyncRepositoryInfo: Identifiable, Sendable {
    var id: String { name }
    let name: String
    let shortName: String

    var displayName: String {
        guard shortName.isEmpty else { return shortName }
        let fileName = URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent
        return fileName.isEmpty ? name : fileName
    }
}

struct OuisyncEntry: Identifiable, Sendable {
    var id: String { path }
    let name: String
    let path: String
    let isDirectory: Bool
}
