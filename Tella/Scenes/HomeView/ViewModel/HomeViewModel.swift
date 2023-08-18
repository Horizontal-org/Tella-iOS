//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    var appModel: MainAppModel
    
    @Published var showingDocumentPicker = false
    @Published var showingAddFileSheet = false
    @Published var serverDataItemArray : [ServerDataItem] = []
    
    var hasRecentFile = false
    
    private var subscribers = Set<AnyCancellable>()
    
    var showingFilesTitle: Bool {
        return (hasRecentFile && appModel.settings.showRecentFiles) || !serverDataItemArray.isEmpty
    }
    
    fileprivate func handleTemplate() {
        do {
            //try appModel.vaultManager.tellaData.database?.deleteAllUwaziTemplate()
           // /*
            Task {
                let servers = self.appModel.vaultManager.tellaData.database?.getServer()
                guard let server = servers?.first,let id = server.id else { return }
                guard let locale = try self.appModel.vaultManager.tellaData.database?.getUwaziLocaleWith(serverId: id) else { return }
                let template = try await UwaziServerRepository().getTemplateNew(server: server, locale: locale)
                template.sink { completion in
                    switch completion {
                    case .finished:
                        print("Fetching template completed.")
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                } receiveValue: { templates in
                    var allTemplates = templates
                    print(allTemplates)
                    do {
//                        if var item = templates.first, let savedItem = try self.appModel.vaultManager.tellaData.database?.addUwaziTemplateWith(template: item) {
//                            item = savedItem
//                            let savedTemplate = try self.appModel.vaultManager.tellaData.database?.getAllUwaziTemplate()
//                            print(savedTemplate)
//                        }

                        // For saving the template into db for add template list
                        if var item = templates[safe: 0] {
                            self.saveTemplate(template: &item)
                        }

                        let savedTemplate = try self.getAllDownloadedTemplate()
                        print(savedTemplate)


                        // For handling the downloaded when the templates are already there
                        //try self.handleTemplateDownload(templates: &allTemplates)


                        // To delete the downloaded template for add template list
//                        if var item = templates[safe: 1] {
//                            self.deleteTemplate(template: &item)
//                        }


                        // To delete the downloaded template from template list
//                        if var item = templates[safe: 1] {
//                            self.deleteDownloadedTemplate(template: item)
//                        }
                        print(allTemplates)
                    } catch let error {
                        print(error)
                    }
                }.store(in: &subscribers)
            }
           //  */
        } catch {

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
                    if let savedItem = try self.appModel.vaultManager.tellaData.database?.addUwaziTemplateWith(template: template) {
                        template = savedItem
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
    /// Delete the saved template from database using the template id of the template and changing the status of isDownloaded property to 0
    /// - Parameter template: The CollectedTemplate Object and changing the status of isDownloaded property to 0
    func deleteTemplate(template: inout CollectedTemplate) {
        do {
            if let templateId = template.templateId {
                _ = try self.appModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateId: templateId)
                template.isDownloaded = 0
            }
        } catch {

        }
    }
    /// Get all the downloaded templates
    /// - Returns: Collection of CollectedTemplate object which are stored in the database
    func getAllDownloadedTemplate() throws -> [CollectedTemplate]? {
        return try self.appModel.vaultManager.tellaData.database?.getAllUwaziTemplate()
    }
    // TODO: Maybe just same the template id only rather than the whole object
    /// Delete the saved template from database using the template id of the template
    /// - Parameter template: The template object which we need to delete 
    func deleteDownloadedTemplate(template: CollectedTemplate) {
        do {
            if let templateId = template.id {
                _ = try self.appModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateNo: templateId)
            }
        } catch {

        }
    }

    init(appModel:MainAppModel) {
        self.appModel = appModel
        getServersList()
        handleTemplate()

    }

    func getServersList() {
            
            self.appModel.vaultManager.tellaData.servers.sink { result in
                
            } receiveValue: { serverArray in
                self.serverDataItemArray.removeAll()
                if !serverArray.isEmpty {
                    // here i group all the tella servers in one array and the third party services in diferents arrays
                    let thirdPartyConnections = serverArray.filter { mapServerTypeFromInt($0.serverType) != .tella }
                    let tellaUploadServers = serverArray.filter { mapServerTypeFromInt($0.serverType) == .tella }
                    if !thirdPartyConnections.isEmpty {
                        self.serverDataItemArray.append(contentsOf: thirdPartyConnections.map { ServerDataItem(servers: [$0], serverType: mapServerTypeFromInt($0.serverType) )})
                    }
                    if !tellaUploadServers.isEmpty {
                        self.serverDataItemArray.append(ServerDataItem(servers: tellaUploadServers, serverType: .tella))
                    }
                }
            }.store(in: &subscribers)
        }
    
    func getFiles() -> [RecentFile] {
        let recentFile = appModel.vaultManager.root.getRecentFile()
        hasRecentFile = recentFile.count > 0
        return recentFile
    }
}
extension Collection {

    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
