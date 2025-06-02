//
//  AddTemplateVM.swift
//  Tella
//
//  Created by Gustavo on 27/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class AddTemplateViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published private var templates : [CollectedTemplate] = []
    
    @Published var templateItemsViewModel : [TemplateItemViewModel] = []
    
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var entityFetcher: UwaziEntityFetcher? = nil
    var toastMessage: String = ""
    var serverName : String = ""
    var subscribers = Set<AnyCancellable>()
    var server: UwaziServer? = nil
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    
    init(mainAppModel : MainAppModel, serverId: Int?) {
        
        self.mainAppModel = mainAppModel
        self.server = self.getServerById(id: serverId!)
        self.serverName = server?.name ?? ""
        self.entityFetcher = UwaziEntityFetcher(
            server: self.server, subscribers: subscribers
        )
    }
    
    func getServerById(id: Int) -> UwaziServer {
        return (self.tellaData?.getUwaziServer(serverId: id))!
    }
    
    func getTemplates() {
        self.isLoading = true
        Task {
            guard let id = self.server?.id else { return }
            let template = UwaziServerRepository().handleTemplate(server: self.server!)
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
        self.isLoading = true
        entityFetcher?.fetchRelationshipEntities(template: template) { result in
            self.handleRelationshipCompletion(template: template, result: result)
                
            self.isLoading = false
        }
    }
    
    func handleRelationshipCompletion(template: CollectedTemplate, result: Result<[UwaziRelationshipList], APIError>) {
        switch result {
        case .success(let relationships):
            template.relationships = relationships
            self.saveTemplate(template: template)
        case .failure(let error):
            self.toastMessage = error.localizedDescription
            self.showToast = true
        }
    }
    
    fileprivate func handleGetTemplateCompletion(_ completion: Subscribers.Completion<APIError>) {
        switch completion {
        case .finished:
            showToast = false
        case .failure(let error):
            self.showToast = true
            self.toastMessage = error.errorMessage
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
    func saveTemplate(template: CollectedTemplate) {
        let savedTemplateid = self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
        if let savedTemplate = savedTemplateid,let templateId = template.templateId {
            if !savedTemplate.contains(templateId) {
                let result = self.tellaData?.addUwaziTemplate(template: template)
                
                handleSaveTemplateCompletion(template: template, result: result)
            }
        }
    }
    
    func handleSaveTemplateCompletion(template: CollectedTemplate, result: Result<CollectedTemplate, Error>?) {
        switch result {
        case .success(let collectedTemplate):
            self.toastMessage = String.init(format: LocalizableUwazi.uwaziAddTemplateSavedToast.localized,
                                       collectedTemplate.entityRow?.name ?? "")
            self.showToast = true
            self.templateItemsViewModel.first(where: {template.templateId == $0.id})?.isDownloaded = true
        case .failure(let error):
            self.showToast = true
            self.toastMessage = error.localizedDescription
        case .none: break
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
}
