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
    
    init(appModel:MainAppModel) {
        self.appModel = appModel
        getServersList()
        do {
            try getTemplate()
        }catch {

        }

    }

    func getTemplate() throws {
        let server = appModel.vaultManager.tellaData.database?.getServer()
        if let firstServer = server?.first, let serverId = firstServer.id {
            let locale = try appModel.vaultManager.tellaData.database?.getUwaziLocaleWith(serverId: serverId)
            let serverURL = firstServer.url ?? ""
            let cookieList = [firstServer.accessToken ?? "" , locale?.locale ?? ""]
            //UwaziServerRepository().handleTemplate(serverURL: firstServer.url ?? "", cookieList: [firstServer.accessToken ?? "" , locale?.locale ?? ""])
//            UwaziServerRepository().getTranslations(serverURL: firstServer.url ?? "", cookieList: cookieList)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { completion in
//                    switch completion {
//                    case .finished:
//                        print("Finished")
//                        // TODO: handle this error
//                    case .failure(let error):
//                       print(error)
//                    }
//
//                }, receiveValue: { wrapper in
//                    print(wrapper)
//                }).store(in: &subscribers)
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
                } receiveValue: { template, setting, dictionary, translation in
                    print(template)
                }.store(in: &subscribers)
//            UwaziServerRepository().getTemplate(serverURL: serverURL, cookieList: cookieList).zip(UwaziServerRepository().getSettings(serverURL: firstServer.url ?? "", cookieList: cookieList))
//                .receive(on: DispatchQueue.main)
//                .sink { completion in
//                switch completion {
//                case .finished:
//                    print("Finished")
//                    // TODO: handle this error
//                case .failure(let error):
//                    print(error)
//                }
//            } receiveValue: { template, setting in
//                print(template)
//            }.store(in: &subscribers)

        }

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
