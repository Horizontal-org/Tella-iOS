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
        let response = UwaziServerRepository().submitEntity(serverURL: serverURL, cookieList: cookieList, entity: entityData, attachments: getFilesInfo())
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
        var entityWrapper: [String: Any] = [:]
        var entityData: [String: Any] = [:]
        var metadata: [String: Any] = [:]
        var attachments: [[String: Any]] = [[:]]
        entityData["attachments"] = attachments

        for entryPrompt in entryPrompts {
            switch UwaziEntityPropertyType(rawValue: entryPrompt.type) {
            case .dataTypeText:
                if entryPrompt.name == "title" {
                    entityData[entryPrompt.name!] = entryPrompt.value.stringValue
                } else {
                    metadata[entryPrompt.name!] = [["value": entryPrompt.value.stringValue]]
                }
            case .dataTypeNumeric:
                metadata[entryPrompt.name!] = [["value": entryPrompt.value.stringValue]]
            case .dataTypeSelect, .dataTypeMultiSelect:
                metadata[entryPrompt.name!] = [["value": entryPrompt.value.selectedValue[0].id, "label": entryPrompt.value.selectedValue[0].label]]
            default:
                break
            }
        }

        entityData["template"] = template!.templateId
        entityData["metadata"] = metadata
        
        if(!files.isEmpty) {
            attachments = extractFilesAsAttachments()
            entityData["attachments"] = attachments
        }

        entityWrapper["entity"] = entityData
        
        return entityWrapper
    }
    
    private func extractFilesAsAttachments() ->[[String: Any]] {
        var attachments = [[String: Any]]()
        for file in files {
            let attachment = [
                "originalname": file.fileName,
                "filename": file.fileName,
                "type": "attachment",
                "mimetype": MIMEType.mime(for: file.fileExtension),
                "entity": "NEW_ENTITY"
            ] as [String: Any]
                    
            attachments.append(attachment)
        }
        
        return attachments
    }
    
    func getFilesInfo() -> [UwaziAttachment] {
        return files.compactMap { file in
            // this is just for testing purpose. We should send the whole file
            if let thumbnail = file.thumbnail {
                return UwaziAttachment(filename: file.fileName, data: thumbnail)
            } else {
                return nil
            }
        }
    }
    private func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
            self.publishUpdates()
        }).store(in: &subscribers)
    }
       
    private func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
        
    var addFileToDraftItems : [ListActionSheetItem] { return [
            
            ListActionSheetItem(imageName: "report.camera-filled",
                                content: LocalizableReport.cameraFilled.localized,
                                type: ManageFileType.camera),
            ListActionSheetItem(imageName: "report.mic-filled",
                                content: LocalizableReport.micFilled.localized,
                                type: ManageFileType.recorder),
            ListActionSheetItem(imageName: "report.gallery",
                                content: LocalizableReport.galleryFilled.localized,
                                type: ManageFileType.tellaFile),
            ListActionSheetItem(imageName: "report.phone",
                                content: LocalizableReport.phoneFilled.localized,
                                type: ManageFileType.fromDevice)
        ]}

}


public struct UwaziAttachment {
    public let filename: String
    public let data: Data
    
    public init(filename: String, data: Data) {
        self.filename = filename
        self.data = data
    }
}
