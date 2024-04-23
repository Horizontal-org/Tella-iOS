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
    
    @Published var draftEntitiesViewModel : [EntityInstanceCardViewModel] = []
    @Published var outboxedEntitiesViewModel : [EntityInstanceCardViewModel] = []
    @Published var submittedEntitiesViewModel : [EntityInstanceCardViewModel] = []
    
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
        return self.mainAppModel.vaultManager.tellaData
    }
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel, server: UwaziServer) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
        
        self.getUwaziInstances()
        self.listenToUpdates()
        
    }
    
    private func getUwaziInstances() {
        
        let draftEntities = tellaData?.getDraftUwaziEntityInstances() ?? []
        let outboxedEntities = tellaData?.getOutboxUwaziEntityInstances() ?? []
        let submittedEntities = tellaData?.getSubmittedUwaziEntityInstances() ?? []
        
        draftEntitiesViewModel = draftEntities.compactMap{ entity in
            EntityInstanceCardViewModel(instance: entity,
                                        deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
        
        outboxedEntitiesViewModel = outboxedEntities.compactMap{ entity in
            EntityInstanceCardViewModel(instance: entity,
                                        deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
        
        submittedEntitiesViewModel = submittedEntities.compactMap{ entity in
            EntityInstanceCardViewModel(instance: entity,
                                        deleteTemplate: { self.deleteEntity(entityId: entity.id)})
        }
    }
    
    func listenToUpdates() {
        self.mainAppModel.vaultManager.tellaData?.shouldReloadUwaziInstances
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
    
    
}




