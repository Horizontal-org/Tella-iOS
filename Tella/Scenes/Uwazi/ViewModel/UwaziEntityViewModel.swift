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
    
    var serverName : String = ""
    var templateName: String = ""
    
    @Published var entryPrompts: [any UwaziEntryPrompt] = []
    @Published var resultFile : [VaultFileDB]?
    
    @Published var showingSuccessMessage : Bool = false
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    
    @Published var uwaziEntityParser : UwaziEntityParser?
    @Published var shouldHideView : Bool = false
    @Published var relationshipEntities: [UwaziRelationshipList] = []
    @Published var entityFetcher: UwaziEntityFetcher? = nil
    
    var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel,
         templateId: Int?,
         entityInstanceId:Int?) {
        
        self.mainAppModel = mainAppModel
        
        let entityInstance = getInstanceById(entityId: entityInstanceId)
        let templateId  = templateId ?? entityInstance?.templateId
        
        guard let templateId, let template = getTemplateById(id: templateId)  else {return}
        guard let server = getServerById(id: template.serverId) else { return }
        
        uwaziEntityParser = UwaziEntityParser(template: template, appModel: mainAppModel, entityInstance: entityInstance)
        entryPrompts = uwaziEntityParser?.getEntryPrompts() ?? []
        uwaziEntityParser?.putAnswers()
        entityFetcher = UwaziEntityFetcher(server: server, subscribers: subscribers)
        
        serverName = template.serverName ?? ""
        templateName = template.entityRow?.name ?? ""
        self.bindVaultFileTaken()
        
        // preload entities in relationship array in case the endpoint fails
        self.relationshipEntities = template.relationships ?? []
        self.fetchRelationships()
    }
    
    func fetchRelationships() {
        guard let template = self.template else { return }
        entityFetcher?.fetchRelationshipEntities(template: template) { relationships in
            self.relationshipEntities = relationships
            template.relationships = relationships
    
            _ = self.tellaData?.updateUwaziTemplate(template: template)
        }
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    
    var entityInstance: UwaziEntityInstance? {
        return self.uwaziEntityParser?.entityInstance
    }
    
    var template: CollectedTemplate? {
        return self.uwaziEntityParser?.template
    }
    
    func getTemplateById (id: Int) -> CollectedTemplate? {
        return (self.tellaData?.getUwaziTemplateById(id: id))
    }
    
    func getServerById(id: Int?) -> UwaziServer? {
        guard let serverId = id else { return nil}
        return (self.tellaData?.getUwaziServer(serverId: serverId))
    }
    
    func getInstanceById (entityId: Int?) -> UwaziEntityInstance? {
        guard let entityId else { return nil}
        
        return (self.tellaData?.database.getUwaziEntityInstance(entityId: entityId))
    }
    
    private func bindVaultFileTaken() {
        $resultFile
            .sink(receiveValue: { [weak self] files in
                
                guard let self = self, let files = files else { return }
                
                let pdfPrompt = self.entryPrompts.filter({$0.type == .dataTypeMultiPDFFiles}).first as? UwaziFilesEntryPrompt
                let multiFilesPrompt = self.entryPrompts.filter({$0.type == .dataTypeMultiFiles}).first as? UwaziFilesEntryPrompt
                
                
                files.forEach { vaultFileDB in
                    let isPDF = vaultFileDB.mimeType?.isPDF ?? false
                    if isPDF {
                        pdfPrompt?.value.insert(files)
                    } else {
                        multiFilesPrompt?.value.insert(files)
                    }
                    
                    self.publishUpdates()
                }
            })
            .store(in: &subscribers)
    }
    
    func handleMandatoryProperties() -> Bool {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        var hasMandatoryErrors = false
        
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError()
            publishUpdates()
        }
        hasMandatoryErrors = requiredPrompts.compactMap({$0.shouldShowMandatoryError}).contains(true)
        
        return hasMandatoryErrors
    }
    
    func saveAnswersToEntityInstance() {
        uwaziEntityParser?.saveAnswersToEntityInstance(status: .draft)
    }
    
    func saveEntityDraft() {
        
        let checkMandatoryFields = self.handleMandatoryProperties()
        
        if !checkMandatoryFields {
            
            saveAnswersToEntityInstance()
            guard let entityInstance = uwaziEntityParser?.entityInstance else { return }

            guard let isSaved = tellaData?.addUwaziEntityInstance(entityInstance: entityInstance) else { return }        
            if isSaved {
                self.shouldHideView = true
                Toast.displayToast(message: "Entity is saved as draft.")
            } else {
                Toast.displayToast(message: LocalizableCommon.commonError.localized)
            }
        }
    }
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
