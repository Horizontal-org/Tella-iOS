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
    
    var pageViewItems : [PageViewItem] {
        [PageViewItem(title: LocalizableUwazi.uwaziPageViewTemplate.localized, page: .template, number: 0),
         PageViewItem(title: "Draft", page: .draft, number: draftEntitiesViewModel.count),
         PageViewItem(title: "outbox", page: .outbox, number: outboxedEntitiesViewModel.count),
         PageViewItem(title: "submitted", page: .submitted, number: submittedEntitiesViewModel.count)]}
    
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
                          deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
        
        outboxedEntitiesViewModel = outboxedEntities.compactMap{ entity in
            UwaziCardViewModel(instance: entity,
                          deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
        
        submittedEntitiesViewModel = submittedEntities.compactMap{ entity in
            UwaziCardViewModel(instance: entity,
                          deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
    }
    
    private func getDownloadedTemplates() {
        self.downloadedTemplates = self.tellaData?.getAllUwaziTemplate() ?? []
        
        self.templateCardsViewModel = self.downloadedTemplates.compactMap({ collectedTemplate in
            
            UwaziCardViewModel(template: collectedTemplate,
                          deleteTemplate: {self.deleteDownloadedTemplate(templateId:collectedTemplate.id)})
        })
    }
    
    
    func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadUwaziInstances
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getUwaziInstances()
            }.store(in: &subscribers)
    }
    
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteEntity(entityId: Int?) {
        guard let entityId else { return }
        self.tellaData?.deleteUwaziEntityInstance(entityId: entityId)
        getUwaziInstances()
    }
    
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(templateId: Int?) {
        guard let templateId else { return }
        self.tellaData?.deleteAllUwaziTemplate(id: templateId)
        getDownloadedTemplates()
    }
    
    
}




