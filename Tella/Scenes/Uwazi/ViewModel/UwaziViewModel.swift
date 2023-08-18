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
    
//    @Published var templates : [UwaziTemplateRow] = []
//    @Published var downloadedTemplates : [UwaziTemplateRow] = []
    @Published var templates : [CollectedTemplate] = []
    @Published var downloadedTemplates : [CollectedTemplate] = []
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.templates
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: "Templates", page: .templates, number: ""),
        PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: "") ,
        PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: ""),
        PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: "")
    ]
    
    @Published var isLoading: Bool = false
    @Published var serverURL : String = "https://"
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
        do {
            Task {
                guard let id = self.server.id else { return }
                guard let locale = try self.mainAppModel.vaultManager.tellaData.database?.getUwaziLocaleWith(serverId: id) else { return }
                let template = try await UwaziServerRepository().getTemplateNew(server: self.server, locale: locale)
                template.receive(on: DispatchQueue.main).sink { completion in
                    switch completion {
                    case .finished:
                        print("Fetching template completed.")
                    case .failure(let error):
                        self.isLoading = false
                        print("Error: \(error)")
                    }
                } receiveValue: { templates in
                    do {
                        var allTemplates = templates
                        try self.handleTemplateDownload(templates: &allTemplates)
                        self.templates = allTemplates
                        self.isLoading = false
                    } catch let error {
                        print(error)
                        self.isLoading = false
                    }

                }.store(in: &subscribers)
            }
        } catch {
            self.isLoading = false
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
                self.deleteDownloadedTemplate(template: template)
                completion()
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
                    if let savedItem = try self.mainAppModel.vaultManager.tellaData.database?.addUwaziTemplateWith(template: template) {
                        template = savedItem
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
    /// Delete the saved template from database using the template id of the template and changing the status of isDownloaded property to 0  for template listing view
    /// - Parameter template: The CollectedTemplate Object and changing the status of isDownloaded property to 0
    func deleteTemplate(template: inout CollectedTemplate) {
        do {
            if let templateId = template.templateId {
                _ = try self.mainAppModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateId: templateId)
                template.isDownloaded = 0
            }
        } catch {

        }
    }
    /// Get all the downloaded templates
    /// - Returns: Collection of CollectedTemplate object which are stored in the database
    func getAllDownloadedTemplate() throws -> [CollectedTemplate]? {
        return try self.mainAppModel.vaultManager.tellaData.database?.getAllUwaziTemplate()
    }

    // TODO: Maybe just same the template id only rather than the whole object
    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(template: CollectedTemplate) {
        do {
            if let templateId = template.id {
                _ = try self.mainAppModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateNo: templateId)
                downloadedTemplates = downloadedTemplates.filter({$0.id != templateId})
            }
        } catch {

        }
    }

    func downloadTemplate(template: CollectedTemplate) -> Void {
        isLoading = true
        // TODO: Try to remove this
        var template = template
        self.saveTemplate(template: &template)
        isLoading = false
        
    }
    
}
