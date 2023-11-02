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
    @Published var accessToken: String = ""
    @Published var serverURL: String = ""
    
    // files
    @Published var files : Set <VaultFile> = []
    @Published var pdfDocuments: Set<VaultFile> = []
    @Published var resultFile : [VaultFile]?
        
    @Published var showingSuccessMessage : Bool = false
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    
    var subscribers = Set<AnyCancellable>()

    init(mainAppModel : MainAppModel, templateId: Int, server: Server) {
        self.mainAppModel = mainAppModel
        self.template = self.getTemplateById(id: templateId)
        self.accessToken = server.accessToken ?? ""
        self.serverURL = server.url ?? ""
        self.bindVaultFileTaken()
        entryPrompts = UwaziEntityParser(template: template!).getEntryPrompts()
        dump(files)
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    
    func getTemplateById (id: Int) -> CollectedTemplate {
        return (self.tellaData?.getUwaziTemplateById(id: id))!
    }
    
    func handleMandatoryProperties() {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
        }
        
        if(!requiredPrompts.isEmpty) {
            submitEntity()
        }
    }
    
    private func submitEntity() {
        // Extract entity data and metadata
        let entityData = extractEntityDataAndMetadata()
        
        // Prepare server URL and cookie list
        let serverURL = self.serverURL
        let cookieList = ["connect.sid=" + self.accessToken]
//         Submit the entity data
        let response = UwaziServerRepository().submitEntity(
            serverURL: serverURL,
            cookieList: cookieList,
            entity: entityData,
            attachments: UwaziFileUtility(files: files, mainAppModel: mainAppModel).getFilesInfo(),
            documents: UwaziFileUtility(files: pdfDocuments, mainAppModel: mainAppModel).getFilesInfo())
               response.sink { completion in
                   switch completion {

                   case .finished:
                       print("Finished")
                   case .failure(let error):
                       print(error)
                   }
                   } receiveValue: { value in
                       print(value)
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
            case .dataTypeText, .dataTypeNumeric:
                metadata[propertyName] = [[UwaziEntityMetadataKeys.value: entryPrompt.value.stringValue]]
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
    
    // files
    private func bindVaultFileTaken() {
        $resultFile
            .compactMap { $0 }
            .sink(receiveValue: { files in
                files.forEach { file in
                    if file.type == .document {
                        self.pdfDocuments.insert(file)
                    } else {
                        self.files.insert(file)
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
}
