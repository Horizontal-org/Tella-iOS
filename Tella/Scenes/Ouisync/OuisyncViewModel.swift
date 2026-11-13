//
//  OuisyncViewModel.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import Foundation
import OuisyncLib

@MainActor
final class OuisyncViewModel: ObservableObject {
    
    @Published var shareToken: String = ""
    @Published private(set) var repositories: [OuisyncRepositoryInfo] = []
    @Published private(set) var selectedRepository: OuisyncRepositoryInfo?
    @Published private(set) var entries: [OuisyncEntry] = []
    
    var canImportRepository: Bool {
        !shareToken.trimmed().isEmpty
    }
    
    private let client: any OuisyncServing
    private let mainAppModel: MainAppModel
    
    init(client: any OuisyncServing, mainAppModel: MainAppModel) {
        self.client = client
        self.mainAppModel = mainAppModel
    }
    
    func start() async {
        await run {
            try await client.start()
            repositories = try await client.listRepositories()
        }
    }
    
    func importRepository() async -> Bool {
        guard canImportRepository else { return false }
        let token = shareToken.trimmed()
        
        return await run {
            try await client.importRepository(shareToken: token)
            shareToken = ""
            repositories = try await client.listRepositories()
            Toast.displayToast(message: LocalizableOuisync.importedRepository.localized)
        }
    }
    
    func openRepository(_ info: OuisyncRepositoryInfo) async -> Bool {
        await run {
            entries = try await client.listEntries(repositoryName: info.name)
            selectedRepository = info
        }
    }
    
    func refreshEntries() async {
        guard let selectedRepository else { return }
        await run {
            entries = try await client.listEntries(
                repositoryName: selectedRepository.name
            )
        }
    }
    
    func saveFileToVault(_ entry: OuisyncEntry) async {
        guard let selectedRepository,
              !entry.isDirectory,
              let manager = mainAppModel.vaultFilesManager else { return }
        await run {
            let fileURL = mainAppModel.vaultManager.createTempFileURL(
                pathExtension: (entry.name as NSString).pathExtension
            )
            try await client.exportFile(repositoryName: selectedRepository.name, path: entry.path, to: fileURL)
            
            let importedFile = ImportedFile(
                urlFile: fileURL,
                parentId: nil,
                shouldPreserveMetadata: true,
                fileSource: .files,
                fileName: (entry.name as NSString).deletingPathExtension
            )
            guard let savedFile = await manager.addVaultFile(importedFile: importedFile),
                  manager.getVaultFile(id: savedFile.id) != nil else {
                throw RuntimeError("Could not save the file to the vault.")
            }
            manager.shouldReloadFiles.send(true)
            Toast.displayToast(message: LocalizableOuisync.savedToVault.localized)
        }
    }
    
    @discardableResult
    private func run(_ work: () async throws -> Void) async -> Bool {
        do {
            try await work()
            return true
        } catch {
            showError(error)
        }
        return false
    }
    
    private func showError(_ error: Error) {
        guard !(error is CancellationError) else { return }
        let message = (error as? RuntimeError)?.message
        ?? (error as? OuisyncError)?.description
        ?? error.localizedDescription
        Toast.displayToast(message: message)
    }
}
