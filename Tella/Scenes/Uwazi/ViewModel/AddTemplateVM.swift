//
//  AddTemplateVM.swift
//  Tella
//
//  Created by Gustavo on 27/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class AddTemplateViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published private var templates : [CollectedTemplate] = []
    
    @Published var templateItemsViewModel : [TemplateItemViewModel] = []
    
    @Published var isLoading: Bool = false
    var serverName : String = ""
    var subscribers = Set<AnyCancellable>()
    var server: UwaziServer? = nil
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, serverId: Int) {
        
        self.mainAppModel = mainAppModel
        self.server = self.getServerById(id: serverId)
        self.serverName = server?.name ?? ""
    }
    
    func getServerById(id: Int) -> UwaziServer {
        return (self.tellaData?.getUwaziServer(serverId: id))!
    }
    
    func getTemplates() {
        self.isLoading = true
        Task {
            guard let id = self.server?.id else { return }
            let template = try await UwaziServerRepository().handleTemplate(server: self.server!)
            template.receive(on: DispatchQueue.main).sink { completion in
                self.handleGetTemplateCompletion(completion)
            } receiveValue: { templates in
                self.handleRecieveValue(self.mapToCollectedTemplate(serverId: id, templates))
            }.store(in: &subscribers)
        }
    }
    
    
    fileprivate func mapToCollectedTemplate(serverId: Int, _ templates: [UwaziTemplateRow]) -> [CollectedTemplate] {
        return templates.map { template in
            return CollectedTemplate(serverId: serverId,
                                     templateId: template.id,
                                     serverName: self.server?.name ?? "",
                                     username: self.server?.username,
                                     entityRow: template,
                                     isDownloaded: false,
                                     isFavorite: false,
                                     isUpdated: false)
        }
    }
    
    func downloadTemplate(template: CollectedTemplate) {
        var template = template
        self.downloadTemplate(template: &template)
        self.templateItemsViewModel.first(where: {template.templateId == $0.id})?.isDownloaded = true
    }
    
    fileprivate func handleGetTemplateCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            debugLog("Fetching template completed.")
        case .failure(let error):
            debugLog("Error: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    fileprivate func handleRecieveValue(_ templates: [CollectedTemplate]) {
        self.handleTemplateDownload(templates: templates)
        self.templates = templates
        self.isLoading = false
        
        self.templateItemsViewModel = self.templates.map({ collectedTemplate in
            TemplateItemViewModel(template: collectedTemplate,
                                  downloadTemplate: {self.downloadTemplate(template: collectedTemplate)} ,
                                  deleteTemplate: {self.deleteTemplate(template:collectedTemplate)})
        })
    }
    
    
    func handleDeleteActionsForAddTemplate(item: ListActionSheetItem, template: CollectedTemplate, completion: ()-> Void) {
        guard let type = item.type as? TemplateActionType else { return }
        if type == .delete {
            self.deleteTemplate(template: template)
            completion()
        }
    }
    
    /// To determine if the templates are already download or not reflect on the UI for template download list
    /// - Parameter templates: Collection of CollectedTemplate to determine if it downloaded or not
    func handleTemplateDownload(templates: [CollectedTemplate]) {
        templates.forEach { template in
            let savedTemplateid = self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
            if let savedTemplate = savedTemplateid,let templateId = template.templateId {
                if savedTemplate.contains(templateId) {
                    template.isDownloaded = true
                }
            }
        }
    }
    
    /// Save the template to the database
    /// - Parameter template: The template that we need to save into the database
    func saveTemplate( template: inout CollectedTemplate) {
        let savedTemplateid = self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
        if let savedTemplate = savedTemplateid,let templateId = template.templateId {
            // To only save the template if it is not already saved Not necessary because the UI will not have a download button if it is already downloaded
            if !savedTemplate.contains(templateId) {
                guard let savedItem = self.tellaData?.addUwaziTemplate(template: template) else { return }
                template = savedItem
            }
        }
    }
    
    /// Delete the saved template from database using the template id of the template and changing the status of isDownloaded property to 0  for template listing view
    /// - Parameter template: The CollectedTemplate Object and changing the status of isDownloaded property to 0
    func deleteTemplate(template: CollectedTemplate) {
        if let templateId = template.templateId {
            _ = self.tellaData?.deleteAllUwaziTemplate(templateId: templateId)
            template.isDownloaded = false
            self.templateItemsViewModel.first(where: {template.templateId == $0.id})?.isDownloaded = false
        }
    }
    
    /// Get all the downloaded templates
    /// - Returns: Collection of CollectedTemplate object which are stored in the database
    func getAllDownloadedTemplate() -> [CollectedTemplate]? {
        self.tellaData?.getAllUwaziTemplate()
    }
    
    
    func downloadTemplate(template: inout CollectedTemplate) -> Void {
        isLoading = true
        self.saveTemplate(template: &template)
        isLoading = false
    }
}
