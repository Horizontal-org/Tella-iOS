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
    var server: UwaziServer? = nil
    
    @Published private var downloadedTemplates : [CollectedTemplate] = []
    
    @Published var templateCardsViewModel : [TemplateCardViewModel] = []

    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, serverId: Int) {
        self.mainAppModel = mainAppModel
        self.server = self.getServerById(id: serverId)
    }

    func getServerById(id: Int) -> UwaziServer {
        return (self.tellaData?.getUwaziServer(serverId: id))!
    }
    
    func getDownloadedTemplates() {
        self.downloadedTemplates = self.tellaData?.getAllUwaziTemplate() ?? []
        self.templateCardsViewModel = self.downloadedTemplates.map({ collectedTemplate in
            TemplateCardViewModel(template: collectedTemplate,
                                  deleteTemplate: {self.deleteDownloadedTemplate(templateId:collectedTemplate.id)},
                                  serverName: self.server?.name ?? "",
                                  serverId: (self.server?.id)!
            )
        })
    }

    /// Delete the saved template from database using the template id of the template for downloaded template listing view
    /// - Parameter template: The template object which we need to delete
    func deleteDownloadedTemplate(templateId: Int?) {
        guard let templateId else { return }
        self.tellaData?.deleteAllUwaziTemplate(id: templateId)
        getDownloadedTemplates()
    }
    
}
