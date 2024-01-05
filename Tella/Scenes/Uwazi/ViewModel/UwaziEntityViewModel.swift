//
//  UwaziEntityViewModel.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UwaziEntityViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var template: CollectedTemplate? = nil
    @Published var entryPrompts: [UwaziEntryPrompt] = []
    
    // files
    @Published var files : Set <VaultFileDB> = []
    @Published var pdfDocuments: Set<VaultFileDB> = []
    @Published var resultFile : [VaultFileDB]?
        
    @Published var showingSuccessMessage : Bool = false
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    
    @Published var isLoading : Bool = false
    @Published var server: UwaziServer? = nil
    
    var subscribers = Set<AnyCancellable>()

    init(mainAppModel : MainAppModel, templateId: Int, serverId: Int) {
        self.mainAppModel = mainAppModel
        self.template = self.getTemplateById(id: templateId)
        self.bindVaultFileTaken()
        self.server = self.getServerById(id: serverId)
        entryPrompts = UwaziEntityParser(template: template!).getEntryPrompts()
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    
    func getTemplateById (id: Int) -> CollectedTemplate {
        return (self.tellaData?.getUwaziTemplateById(id: id))!
    }
    
    func getServerById(id: Int) -> UwaziServer {
        return (self.tellaData?.getUwaziServer(serverId: id))!
    }
    
    
    func getEntityTitle() -> String {
        return self.entryPrompts.first(where: { $0.name == UwaziEntityMetadataKeys.title })?.value.stringValue ?? ""
    }
    
    func handleMandatoryProperties() -> Bool {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        var hasMandatoryErrors = false
        
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
            if prompt.value.stringValue.isEmpty {
                prompt.showMandatoryError = true
                hasMandatoryErrors = true
            }
        }
        
        return hasMandatoryErrors
    }
    
    func submitEntity(onCompletion: @escaping () -> Void) {
        self.isLoading = true
        // Extract entity data and metadata
        let entityData = extractEntityDataAndMetadata()
        
//         Submit the entity data
        let (body, contentTypeHeader) = UwaziMultipartFormDataBuilder.createBodyWith(
            keyValues: entityData,
            attachments: UwaziFileUtility(files: files, mainAppModel: mainAppModel).getFilesInfo(),
            documents: UwaziFileUtility(files: pdfDocuments, mainAppModel: mainAppModel).getFilesInfo()
        )

        let response = UwaziServerRepository().submitEntity(
            serverURL: self.server?.url ?? "",
            cookie: self.server?.cookie ?? "",
            multipartHeader: contentTypeHeader,
            multipartBody: body
        )
        response
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    debugLog("Finished")
                    Toast.displayToast(message: LocalizableUwazi.uwaziEntitySubmitted.localized)
                    onCompletion()
                case .failure(let error):
                    debugLog(error.localizedDescription)
                    Toast.displayToast(message: LocalizableUwazi.uwaziEntityFailedSubmission.localized)
                }
            } receiveValue: { value in
                debugLog(value)
            }
            .store(in: &subscribers)
    }

    private func extractEntityDataAndMetadata() -> ([String: Any]) {
        let attachments = extractAttachmentsIfAny()
        let documents = extractDocumentsIfAny()
        
        var entityData: [String: Any] = [
            UwaziEntityMetadataKeys.attachments: attachments,
            UwaziEntityMetadataKeys.documents: documents,
            UwaziEntityMetadataKeys.template: template?.templateId ?? ""
        ]
            
        var metadata: [String: Any] = [:]

        for entryPrompt in entryPrompts {
            guard let propertyName = entryPrompt.name else { break }
            
            switch UwaziEntityPropertyType(rawValue: entryPrompt.type) {
            case .dataTypeText where propertyName == UwaziEntityMetadataKeys.title:
                entityData[propertyName] = entryPrompt.value.stringValue
            case .dataTypeText, .dataTypeNumeric, .dataTypeMarkdown:
                metadata[propertyName] = [[UwaziEntityMetadataKeys.value: entryPrompt.value.stringValue]]
            case .dataTypeDate:
                metadata[propertyName] = [[UwaziEntityMetadataKeys.value: Int(entryPrompt.value.stringValue)]]
            case .dataTypeSelect, .dataTypeMultiSelect:
                if let selectedValue = entryPrompt.value.selectedValue.first {
                    metadata[propertyName] = [[UwaziEntityMetadataKeys.value: selectedValue.id, UwaziEntityMetadataKeys.label: selectedValue.label]]
                }
            default:
                break
            }
        }
        
        entityData[UwaziEntityMetadataKeys.metadata] = metadata
        
        return [UwaziEntityMetadataKeys.entity: entityData]
    }
    
    
    private func extractAttachmentsIfAny() -> [[String: Any]] {
        !files.isEmpty ? UwaziFileUtility(files: files).extractFilesAsAttachments() : []
    }

    private func extractDocumentsIfAny() -> [[String: Any]] {
        !pdfDocuments.isEmpty ? UwaziFileUtility(files: pdfDocuments).extractFilesAsAttachments() : []
    }
    
    func getEntityResponseSize() -> String {
        do {
            let entityData = extractEntityDataAndMetadata()
            let jsonData = try JSONSerialization.data(withJSONObject: entityData, options: [])
            let sizeInBytes = Int(jsonData.count)
            let sizeInMB = sizeInBytes.getFormattedFileSize()
            return sizeInMB
        } catch {
            debugLog(error)
            return "\(error)"
        }
    }
    
    // files
    private func bindVaultFileTaken() {
        $resultFile
            .sink(receiveValue: { [weak self] files in
                // Unwrap files safely
                guard let self = self, let files = files else { return }

                files.forEach { file in
                    if file.tellaFileType == .document {
                        self.pdfDocuments.insert(file)
                        self.toggleShowClear(forId: "10242050", value: true)
                    } else {
                        self.files.insert(file)
                        self.toggleShowClear(forId: "10242049", value: true)
                    }
                }
                self.publishUpdates()
            })
            .store(in: &subscribers)
    }
    

    private func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func toggleShowClear(forId id: String, value: Bool) {
        for entryPrompt in entryPrompts {
            if entryPrompt.id == id {
                entryPrompt.showClear = value
                break
            }
        }
    }
    
    func clearValues(forId id: String) {
        if id == "10242050" {
            pdfDocuments.removeAll()
        } else if id == "10242049" {
            files.removeAll()
        } else {
            if let index = entryPrompts.firstIndex(where: { $0.id == id }) {
                entryPrompts[index].value.stringValue = ""
                entryPrompts[index].value.selectedValue = []
            }

        }
        
        toggleShowClear(forId: id, value: false)
    }
}
