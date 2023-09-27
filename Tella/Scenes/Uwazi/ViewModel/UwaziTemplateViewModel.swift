//
//  UwaziTemplateViewModel.swift
//  Tella
//
//  Created by Gustavo on 31/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class UwaziTemplateViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published private var templates : [CollectedTemplate] = []
    @Published private var downloadedTemplates : [CollectedTemplate] = []
    
    @Published var templateItemsViewModel : [TemplateItemViewModel] = []
    @Published var templateCardsViewModel : [TemplateCardViewModel] = []
    
    @Published var isLoading: Bool = false
    @Published var serverName : String
    var subscribers = Set<AnyCancellable>()
    var server: Server
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, server: Server) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
    }
    
    func getTemplates() {
        self.isLoading = true
        Task {
            guard let id = self.server.id else { return }
            guard let locale = self.tellaData?.getUwaziLocale(serverId: id) else { return }
            let template = try await UwaziServerRepository().handleTemplate(server: self.server, locale: locale)
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
                                     serverName: self.server.name ?? "",
                                     username: self.server.username,
                                     entityRow: template,
                                     isDownloaded: false,
                                     isFavorite: false,
                                     isUpdated: false)
        }
    }
    
    func downloadTemplate(template: CollectedTemplate) {
        var template = template
        Toast.displayToast(message: "“\(template.entityRow?.translatedName ?? "")” “\(LocalizableUwazi.uwaziAddTemplateSavedToast.localized)”")
        self.downloadTemplate(template: &template)
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
                                  deleteTemplate: {self.deleteDownloadedTemplate(templateId:collectedTemplate.id)})
        })
    }
    
    func getDownloadedTemplates() {
        self.downloadedTemplates = self.getAllDownloadedTemplate() ?? []
        
        self.templateCardsViewModel = self.downloadedTemplates.map({ collectedTemplate in
            TemplateCardViewModel(template: collectedTemplate,
                                  deleteTemplate: {self.deleteDownloadedTemplate(templateId:collectedTemplate.id)})
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
        }
    }
    
    /// Get all the downloaded templates
    /// - Returns: Collection of CollectedTemplate object which are stored in the database
    func getAllDownloadedTemplate() -> [CollectedTemplate]? {
        self.tellaData?.getAllUwaziTemplate()
    }
    
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(templateId: Int?) {
        guard let templateId else { return }
        self.tellaData?.deleteAllUwaziTemplate(id: templateId)
        getDownloadedTemplates()
    }
    
    func downloadTemplate(template: inout CollectedTemplate) -> Void {
        isLoading = true
        self.saveTemplate(template: &template)
        isLoading = false
    }
}
