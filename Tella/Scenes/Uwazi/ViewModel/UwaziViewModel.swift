//
//  UwaziViewModel.swift
//  Tella
//
//  Created by Gustavo on 25/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class UwaziViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var templates : [CollectedTemplate] = []
    @Published var downloadedTemplates : [CollectedTemplate] = []
    
    @Published var templateCardsViewModel : [UwaziCardViewModel] = []
    
    @Published var draftEntitiesViewModel : [UwaziCardViewModel] = []
    @Published var outboxedEntitiesViewModel : [UwaziCardViewModel] = []
    @Published var submittedEntitiesViewModel : [UwaziCardViewModel] = []
    
    @Published var selectedCell = Pages.template
    @Published var isLoading: Bool = false
    @Published var serverName : String
    
    @Published var shouldShowToast : Bool = false
    @Published var toastMessage : String = ""
    
    var pageViewItems : [PageViewItem] {
        [PageViewItem(title: LocalizableUwazi.uwaziPageViewTemplate.localized,
                      page: .template,
                      number: 0),
         PageViewItem(title: LocalizableUwazi.uwaziPageViewDraft.localized,
                      page: .draft,
                      number: draftEntitiesViewModel.count),
         PageViewItem(title: LocalizableUwazi.uwaziPageViewOutbox.localized,
                      page: .outbox,
                      number: outboxedEntitiesViewModel.count),
         PageViewItem(title: LocalizableUwazi.uwaziPageViewSubmitted.localized, 
                      page: .submitted,
                      number: submittedEntitiesViewModel.count)]}
    
    var server: UwaziServer
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel, server: UwaziServer) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
        
        self.getDownloadedTemplates()
        
        self.getUwaziInstances()
        self.listenToUpdates()
        
    }
    
    private func getUwaziInstances() {
        
        let draftEntities = tellaData?.getDraftUwaziEntityInstances() ?? []
        let outboxedEntities = tellaData?.getOutboxUwaziEntityInstances() ?? []
        let submittedEntities = tellaData?.getSubmittedUwaziEntityInstances() ?? []
        
        draftEntitiesViewModel = draftEntities.compactMap{ entity in
            UwaziCardViewModel(instance: entity,
                               deleteTemplate: { self.deleteEntity(entity: entity)})
        }
        
        outboxedEntitiesViewModel = outboxedEntities.compactMap{ entity in
            UwaziCardViewModel(instance: entity,
                               deleteTemplate: { self.deleteEntity(entity: entity)})
        }
        
        submittedEntitiesViewModel = submittedEntities.compactMap{ entity in
            UwaziCardViewModel(instance: entity,
                               deleteTemplate: { self.deleteEntity(entity: entity)})
        }
    }
    
    private func getDownloadedTemplates() {
        self.downloadedTemplates = self.tellaData?.getAllUwaziTemplate() ?? []
        
        self.templateCardsViewModel = self.downloadedTemplates.compactMap({ collectedTemplate in
            
            UwaziCardViewModel(template: collectedTemplate,
                               deleteTemplate: {self.deleteDownloadedTemplate(template:collectedTemplate)})
        })
    }
    
    func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadUwaziInstances
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getUwaziInstances()
            }.store(in: &subscribers)
        
        self.mainAppModel.tellaData?.shouldReloadUwaziTemplates
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getDownloadedTemplates()
            }.store(in: &subscribers)
    }
    
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteEntity(entity:UwaziEntityInstance) {
        
        guard let entityId = entity.id else { return }
        
        let resultDeletion = self.tellaData?.deleteUwaziEntityInstance(entityId: entityId)
        
        var message = ""
        if case .success = resultDeletion {
            message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, entity.title ?? "")
        } else {
            message = LocalizableCommon.commonError.localized
        }
        
        self.shouldShowToast = true
        self.toastMessage = message
    }
    
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(template:CollectedTemplate) {
        
        
        guard let templateId = template.id  else { return }
        
        let resultDeletion =  self.tellaData?.deleteUwaziTemplate(id: templateId)
        
        var message = ""
        if case .success = resultDeletion {
            message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, template.entityRow?.translatedName ?? "")
            getDownloadedTemplates()
            
        } else {
            message = LocalizableCommon.commonError.localized
        }
        
        self.shouldShowToast = true
        self.toastMessage = message
    }
}




