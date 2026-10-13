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
    }
}

extension CameraMediaImporter {
    
    // MARK: - Saving
    
    func save(_ capture: CameraService.CapturedPhoto) {
        let shouldPreserveMetadata = mainAppModel.settings.preserveMetadata
        let url = mainAppModel.vaultManager.createTempFileURL(pathExtension: FileExtension.heic.rawValue)
        // Preparing the HEIC is synchronous; the vault import already handles its own background work.
        photoProcessingQueue.async {
            do {
                try capture.photo.saveImage(to: url,
                                            shouldPreserveMetadata: shouldPreserveMetadata,
                                            aspectRatio: capture.aspectRatio)
                DispatchQueue.main.async { self.importFile(at: url) }
            } catch {
                debugLog("Unable to save photo: \(error.localizedDescription)")
                try? FileManager.default.removeItem(at: url)
                DispatchQueue.main.async { self.onFailure?(error) }
            }
        }
    }
    
    func save(videoAt url: URL) {
        importFile(at: url)
    }
}

private extension CameraMediaImporter {
    
    // MARK: - Vault import
    
    func importFile(at url: URL) {
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
