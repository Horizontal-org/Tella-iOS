//
//  DownloadedTemplatesVM.swift
//  Tella
//
//  Created by Gustavo on 27/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DownloadedTemplatesViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published private var downloadedTemplates : [CollectedTemplate] = []
    
    @Published var templateCardsViewModel : [TemplateCardViewModel] = []
    
    @Published var isLoading: Bool = false
    @Published var serverName : String
    
    var server: Server
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, server: Server) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
    }

    
    func getDownloadedTemplates() {
        self.downloadedTemplates = self.getAllDownloadedTemplate() ?? []
        
        self.templateCardsViewModel = self.downloadedTemplates.map({ collectedTemplate in
            TemplateCardViewModel(template: collectedTemplate,
                                  deleteTemplate: {self.deleteDownloadedTemplate(templateId:collectedTemplate.id)})
        })
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
    
}
