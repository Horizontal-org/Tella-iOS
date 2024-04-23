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
    
    @Published var isLoading : Bool = false
    @Published var uwaziEntityParser : UwaziEntityParser?
    
    var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel,
         templateId: Int?,
         entityInstanceId:Int?) {
        
        self.mainAppModel = mainAppModel
        
        let entityInstance = getInstanceById(entityId: entityInstanceId)
        
        let templateId  = templateId ?? entityInstance?.templateId
        
        guard let templateId, let template = getTemplateById(id: templateId)  else {return}
        
        uwaziEntityParser = UwaziEntityParser(template: template, appModel: mainAppModel, entityInstance: entityInstance)
        entryPrompts = uwaziEntityParser?.getEntryPrompts() ?? []
        uwaziEntityParser?.putAnswers()
        
        serverName = template.serverName ?? ""
        templateName = template.entityRow?.name ?? ""
        
        self.bindVaultFileTaken()
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    
    var entityInstance: UwaziEntityInstance? {
        return self.uwaziEntityParser?.entityInstance
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
    
//    func getEntityTitle() -> String {
//        return self.entryPrompts.first(where: { $0.name == UwaziEntityMetadataKeys.title })?.value.stringValue ?? ""
//    }
    
    func handleMandatoryProperties() -> Bool {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        var hasMandatoryErrors = false
        
        requiredPrompts.forEach { prompt in
            
//            let isEmpty = (prompt.value.value as AnyObject).isEmpty
//            prompt.showMandatoryError = isEmpty ?? false
            prompt.showMandatoryError()
            publishUpdates()

        }
        hasMandatoryErrors = requiredPrompts.compactMap({$0.shouldShowMandatoryError}).contains(true)
        
        return hasMandatoryErrors
    }
    
//    // MARK: Submit Entity
//    
//    func submitEntityLaterr(onCompletion: @escaping () -> Void) {
////        saveEntity(status: .finalized)
//    }
    
    
    func saveAnswersToEntityInstance() {
        uwaziEntityParser?.saveAnswersToEntityInstance(status: .draft)
    }

    // files
    private func bindVaultFileTaken() {
        $resultFile
            .sink(receiveValue: { [weak self] files in
                // Unwrap files safely
                
                guard let self = self, let files = files else { return }
                
                let pdfPrompt = self.entryPrompts.filter({$0.type == .dataTypeMultiPDFFiles}).first as? UwaziFilesEntryPrompt
                let multiFilesPrompt = self.entryPrompts.filter({$0.type == .dataTypeMultiFiles}).first as? UwaziFilesEntryPrompt
                
                
                files.forEach { vaultFileDB in
                    let isPDF = vaultFileDB.mimeType?.isPDF ?? false
                    if isPDF {
                        pdfPrompt?.value.value.insert(files)
                    } else {
                        multiFilesPrompt?.value.value.insert(files)
                    }
                    
                    self.publishUpdates()
                }
            })
            .store(in: &subscribers)
    }
    
    
   func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
