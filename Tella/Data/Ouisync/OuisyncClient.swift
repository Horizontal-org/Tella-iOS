//
//  OuisyncServing.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

protocol OuisyncServing: AnyObject, Sendable {

    func start() async throws

    func listRepositories() async throws -> [OuisyncRepositoryInfo]
    func importRepository(shareToken: String) async throws
    func listEntries(repositoryName: String) async throws -> [OuisyncEntry]

    func exportFile(repositoryName: String, path: String, to destinationURL: URL) async throws
}
