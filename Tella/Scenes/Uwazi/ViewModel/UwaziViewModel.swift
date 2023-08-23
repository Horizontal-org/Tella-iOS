//
//  UwaziViewModel.swift
//  Tella
//
//  Created by Gustavo on 31/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class UwaziReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel

    @Published var templates : [CollectedTemplate] = []
    @Published var downloadedTemplates : [CollectedTemplate] = []
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.templates
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: LocalizableUwazi.uwaziPageViewTemplate.localized, page: .templates, number: ""),
        PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: "") ,
        PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: ""),
        PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: "")
    ]
    
    @Published var isLoading: Bool = false
    @Published var serverURL : String
    @Published var serverName : String
    
    var subscribers = Set<AnyCancellable>()

    var server: Server
    
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status?.sheetItemTitle ?? "",
                            type: self.selectedReport?.status?.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ReportActionType.delete)
    ]}
    
    
    init(mainAppModel : MainAppModel, server: Server) {
        
        self.mainAppModel = mainAppModel
        dump(server)
        self.server = server
        self.serverURL = server.url ?? ""
        self.serverName = server.name ?? ""
    }


    func getTemplates() {
        self.isLoading = true
            Task {
                guard let id = self.server.id else { return }
                guard let locale = try self.mainAppModel.vaultManager.tellaData.getUwaziLocale(serverId: id) else { return }
                let template = try await UwaziServerRepository().getTemplateNew(server: self.server, locale: locale)
                template.receive(on: DispatchQueue.main).sink { completion in
                    switch completion {
                    case .finished:
                        dump("Fetching template completed.")
                    case .failure(let error):
                        self.isLoading = false
                        dump("Error: \(error)")
                    }
                } receiveValue: { templates in
                    do {
                        var allTemplates = templates
                        try self.handleTemplateDownload(templates: &allTemplates)
                        self.templates = allTemplates
                        self.isLoading = false
                    } catch let error {
                        dump(error)
                        self.isLoading = false
                    }

                }.store(in: &subscribers)
            }
    }
    func getDownloadedTemplates() {
        do {
            try self.downloadedTemplates = self.getAllDownloadedTemplate() ?? []
        } catch {

        }
    }

    func handleActions(item: ListActionSheetItem, template: CollectedTemplate, completion: ()-> Void) {
        if let type = item.type as? TemplateActionType {
            if type == .delete {
                var template = template
                self.deleteTemplate(template: &template)
                completion()
            }
        } else if let type = item.type as? DownloadedTemplateActionType {
            if type == .delete {
                if let templateId = template.id {
                    self.deleteDownloadedTemplate(templateId: templateId)
                    completion()
                }
            }
        }
    }

    /// To determine if the templates are already download or not reflect on the UI for template download list
    /// - Parameter templates: Collection of CollectedTemplate to determine if it downloaded or not
    func handleTemplateDownload(templates: inout [CollectedTemplate]) throws {
        try templates.forEach { template in
            let savedTemplateid = try self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
            if let savedTemplate = savedTemplateid,let templateId = template.templateId {
                if savedTemplate.contains(templateId) {
                    template.isDownloaded = 1
                }
            }
        }
    }
    /// Save the template to the database
    /// - Parameter template: The template that we need to save into the database
    func saveTemplate( template: inout CollectedTemplate) {
        do {
            let savedTemplateid = try self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
            if let savedTemplate = savedTemplateid,let templateId = template.templateId {
                // To only save the template if it is not already saved Not necessary because the UI will not have a download button if it is already downloaded
                if !savedTemplate.contains(templateId) {
                    let savedItem = try self.mainAppModel.vaultManager.tellaData.addUwaziTemplate(template: template)
                    template = savedItem
                }
            }
        } catch let error {
            dump(error)
        }
    }
    /// Delete the saved template from database using the template id of the template and changing the status of isDownloaded property to 0  for template listing view
    /// - Parameter template: The CollectedTemplate Object and changing the status of isDownloaded property to 0
    func deleteTemplate(template: inout CollectedTemplate) {
        do {
            if let templateId = template.templateId {
                _ = try self.mainAppModel.vaultManager.tellaData.deleteAllUwaziTemplate(templateId: templateId)
                template.isDownloaded = 0
            }
        } catch let error{
            debugLog(error)
        }
    }
    /// Get all the downloaded templates
    /// - Returns: Collection of CollectedTemplate object which are stored in the database
    func getAllDownloadedTemplate() throws -> [CollectedTemplate]? {
        return try self.mainAppModel.vaultManager.tellaData.getAllUwaziTemplate()
    }

    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(templateId: Int) {
        do {
            try self.mainAppModel.vaultManager.tellaData.deleteAllUwaziTemplate(id: templateId)
            downloadedTemplates.removeAll{ $0.id == templateId}
        } catch let error {
            debugLog(error)
        }
    }

    func downloadTemplate(template: inout CollectedTemplate) -> Void {
        isLoading = true
        self.saveTemplate(template: &template)
        isLoading = false
        
    }
    
}
