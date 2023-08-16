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
                var template = try await getTemplate(server: server, locale: locale)
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
//                        if var item = templates[safe: 1] {
//                            self.saveTemplate(template: &item)
//                        }


                        // For handling the downloaded when the templates are already there
                        //try self.handleDownloadStuff(templates: &allTemplates)


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
    func handleDownloadStuff(templates: inout [CollectedTemplate]) throws {
        try templates.forEach { template in
            let savedTemplateid = try self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
            if let savedTemplate = savedTemplateid,let templateId = template.templateId {
                if savedTemplate.contains(templateId) {
                    template.isDownloaded = 1
                }
            }
        }
    }

    func saveTemplate( template: inout CollectedTemplate) {
        do {
            let savedTemplateid = try self.getAllDownloadedTemplate()?.compactMap({$0.templateId})
            if let savedTemplate = savedTemplateid,let templateId = template.templateId {
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
    func deleteTemplate(template: inout CollectedTemplate) {
        do {
            if let templateId = template.templateId {
                _ = try self.appModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateId: templateId)
                template.isDownloaded = 0
            }
        } catch {

        }
    }
    func getAllDownloadedTemplate() throws -> [CollectedTemplate]? {
        return try self.appModel.vaultManager.tellaData.database?.getAllUwaziTemplate()
    }
    func deleteDownloadedTemplate(template: CollectedTemplate) {
        do {
            if let templateId = template.templateId {
                _ = try self.appModel.vaultManager.tellaData.database?.deleteAllUwaziTemplateWith(templateId: templateId)
            }
        } catch {

        }
    }

    init(appModel:MainAppModel) {
        self.appModel = appModel
        getServersList()
        handleTemplate()

    }

    func getTemplate(server: Server, locale: UwaziLocale) async throws  -> AnyPublisher<[CollectedTemplate], Error> {
        return Future { promise in
            Task {

                if let _ = server.id, let serverURL = server.url {
                    let cookieList = [server.accessToken ?? "" , locale.locale ?? ""]
                    // TODO: Try to use async await
                    let getTemplate = UwaziServerRepository().getTemplate(serverURL: serverURL, cookieList: cookieList)
                    let getSetting = UwaziServerRepository().getSettings(serverURL: serverURL, cookieList: cookieList)
                    let getDictionary = UwaziServerRepository().getDictionaries(serverURL: serverURL, cookieList: cookieList)
                    let getTranslation = UwaziServerRepository().getTranslations(serverURL: serverURL, cookieList: cookieList)

                    Publishers.Zip4(getTemplate, getSetting, getDictionary, getTranslation)
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .finished:
                                print("Finished")
                                // TODO: handle this error
                            case .failure(let error):
                                print(error)
                            }
                        } receiveValue: { templateResult, settings, dictionary, translationResult in
                            let templates = templateResult.rows
                            let translations = translationResult.rows
                            let dictionary = dictionary.rows
                            templates.forEach { template in
                                template.properties.forEach { property in
                                    dictionary.forEach { dictionaryItem in
                                        if dictionaryItem.id == property.content {
                                            property.values = dictionaryItem.values
                                        }
                                    }
                                }
                            }

                            var resultTemplates = [UwaziTemplate]()
                            if (server.username?.isEmpty ?? true) || (server.password?.isEmpty ?? true) {
                                if !settings.allowedPublicTemplates.isEmpty {
                                    templates.forEach { row in
                                        settings.allowedPublicTemplates.forEach { id in
                                            if row.id == id {
                                                resultTemplates.append(row)
                                            }
                                        }
                                    }
                                }
                            } else {
                                resultTemplates = templates
                            }
                            resultTemplates.forEach { template in
                                let filteredTranslations = translations.filter { row in
                                    row.locale == locale.locale ?? ""
                                }
                                filteredTranslations.first?.contexts.forEach{ context in
                                    if context.contextID == template.id {
                                        template.translatedName = context.values?[template.name ?? ""] ?? ""
                                        template.properties.forEach { property in
                                            property.translatedLabel = context.values?[property.label ?? ""] ?? ""
                                        }

                                        template.commonProperties.forEach { property in
                                            property.translatedLabel = context.values?[property.label ?? ""] ?? ""
                                        }


                                    } else {
                                        template.properties.forEach { property in
                                            property.values?.forEach { selectValue in
                                                if context.contextID == property.content {
                                                    selectValue.translatedLabel = context.values?[selectValue.label ?? ""] ?? selectValue.label
                                                }
                                                selectValue.values?.forEach { nestedSelectValue in
                                                    if context.id == property.content {
                                                        nestedSelectValue.translatedLabel = context.values?[nestedSelectValue.label ?? ""] ?? nestedSelectValue.label
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            print(resultTemplates)

                            let originalTemplate = resultTemplates.map { template in
                                return CollectedTemplate(serverId: server.id, templateId: template.id, serverName: server.name ?? "", username: server.username, entityRow: template, isDownloaded: 0, isFavorite: 0, isUpdated: 0 )
                            }
                            promise(.success(originalTemplate))
                        }.store(in: &self.subscribers)

                }
            }

        }.eraseToAnyPublisher()


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
