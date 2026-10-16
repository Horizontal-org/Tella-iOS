//
//  CameraMediaImporter.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation
import Combine
import SwiftUI

/// Turns a finished capture into a vault file.

final class CameraMediaImporter {
    
    // MARK: - UI hooks (main queue)
    
    var onProgress: ((ImportProgress) -> Void)?
    var onFilesAdded: (([VaultFileDB]) -> Void)?
    var onFailure: ((Error) -> Void)?
    
    // MARK: - Dependencies
    
    private let mainAppModel: MainAppModel
    private let rootFile: VaultFileDB?
    private let resultFile: Binding<[VaultFileDB]?>?
    private let autoUpload: Bool
    private let photoProcessingQueue = DispatchQueue(label: "org.tella.camera.photo-processing",
                                                     qos: .userInitiated,
                                                     autoreleaseFrequency: .workItem)
    private var importCancellable: AnyCancellable?
    private var lockCancellable: AnyCancellable?
    private let cancellation = Locked(false)

    private var isCancelled: Bool {
        cancellation.withValue { $0 }
    }

    var reportsProgress: Bool {
        resultFile != nil
    }
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFileDB?,
         resultFile: Binding<[VaultFileDB]?>?,
         sourceView: SourceView) {
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile
        self.resultFile = resultFile
        self.autoUpload = sourceView != .addReportFile
        // Stay subscribed while capture tasks or queued photo processing retain this importer.
        // Handle the lock synchronously, before the app sweeps the temporary directory.
        lockCancellable = mainAppModel.$shouldSaveCurrentData
            .filter { $0 }
            .sink { [weak self] _ in self?.cancelImports() }
    }
}

extension CameraMediaImporter {
    
    // MARK: - Saving
    
    func save(_ capture: CameraService.CapturedPhoto) {
        guard !isCancelled else { return }
        let shouldPreserveMetadata = mainAppModel.settings.preserveMetadata
        let url = mainAppModel.vaultManager.createTempFileURL(pathExtension: FileExtension.heic.rawValue)
        // Preparing the HEIC is synchronous; the vault import already handles its own background work.
        photoProcessingQueue.async {
            guard !self.isCancelled else { return }
            do {
                try capture.photo.saveImage(to: url,
                                            shouldPreserveMetadata: shouldPreserveMetadata,
                                            aspectRatio: capture.aspectRatio)
                // Encoding may finish after the lock's temporary-directory cleanup.
                guard !self.isCancelled else {
                    try? FileManager.default.removeItem(at: url)
                    return
                }
                DispatchQueue.main.async { self.importFile(at: url) }
            } catch {
                debugLog("Unable to save photo: \(error.localizedDescription)")
                try? FileManager.default.removeItem(at: url)
                DispatchQueue.main.async {
                    guard !self.isCancelled else { return }
                    self.onFailure?(error)
                }
            }
        }
    }
    
    func save(videoAt url: URL) {
        importFile(at: url)
    }
}

private extension CameraMediaImporter {

    func cancelImports() {
        cancellation.withValue { $0 = true }
        importCancellable = nil
    }
    
    // MARK: - Vault import
    
    func importFile(at url: URL) {
        // Also covers videos and photos already waiting on the main queue when locking starts.
        guard !isCancelled else {
            try? FileManager.default.removeItem(at: url)
            return
        }
        let importedFile = ImportedFile(urlFile: url,
                                        parentId: rootFile?.id,
                                        shouldPreserveMetadata: mainAppModel.settings.preserveMetadata,
                                        fileSource: .camera)
        if reportsProgress {
            importWithProgress(importedFile)
        } else {
            mainAppModel.addVaultFile(importedFiles: [importedFile], autoUpload: autoUpload)
        }
    }
    
    func importWithProgress(_ importedFile: ImportedFile) {
        // The value handler keeps this importer alive after the camera screen closes.
        // Release the subscription on completion, after the final progress update is delivered.
        importCancellable = mainAppModel.vaultFilesManager?
            .addVaultFile(importedFiles: [importedFile])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.importCancellable = nil
            }, receiveValue: { [self] result in
                guard !self.isCancelled else { return }
                switch result {
                case .importProgress(let importProgress):
                    self.onProgress?(importProgress)
                case .fileAdded(let vaultFiles):
                    self.resultFile?.wrappedValue = vaultFiles
                    self.onFilesAdded?(vaultFiles)
                }
            })
    }
}
