//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var appViewState: AppViewState
    
    @Published var showingAddFileSheet = false
    @Published var serverDataItemArray : [ServerDataItem] = []
    @Published var recentFiles : [VaultFileDB] = []
    @Published var items : [BackgroundActivityModel] = []
    private var subscribers = Set<AnyCancellable>()
    
    var hasRecentFile = false
    
    
    var showingFilesTitle: Bool {
        return (hasRecentFile && mainAppModel.settings.showRecentFiles) || !serverDataItemArray.isEmpty
    }
    init(appViewState: AppViewState) {
        self.mainAppModel = appViewState.homeViewModel
        self.appViewState = appViewState
        getServersList()
        listenToShouldReloadFiles()
        listenToBackgroundItems()
    }
    
    func getServersList() {
        
        self.getServers()
        
        self.mainAppModel.tellaData?.shouldReloadServers
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { shouldReload in
                if shouldReload {
                    self.getServers()
                }
            }.store(in: &subscribers)
    }
    
    func getServers() {
        
        self.serverDataItemArray.removeAll()
        
        let serverArray = self.mainAppModel.tellaData?.getServers() ?? []
        
        var serverConnections: [ServerConnectionType: [Server]] = [:]
        
        for server in serverArray {
            guard let serverType = server.serverType else { continue }
            serverConnections[serverType, default: []].append(server)
        }
        
        for (serverType, servers) in serverConnections {
            self.serverDataItemArray.append(ServerDataItem(servers: servers, serverType: serverType ))
        }
    }
    
    private func listenToBackgroundItems() {
        mainAppModel.encryptionService?.$backgroundItems
            .sink(receiveValue: { items in
                self.items = items
            }).store(in: &subscribers)
    }
    
    func getFiles()   {
        recentFiles = mainAppModel.vaultFilesManager?.getRecentVaultFiles() ?? []
        hasRecentFile = recentFiles.count > 0
    }
    
    func deleteAllVaultFiles()   {
        mainAppModel.vaultFilesManager?.deleteAllVaultFiles()
    }
    
    func deleteAllServersConnection()   {
        mainAppModel.tellaData?.deleteAllServers()
    }
    
    private func listenToShouldReloadFiles() {
        self.mainAppModel.vaultFilesManager?.shouldReloadFiles
            .sink(receiveValue: { shouldReloadVaultFiles in
                DispatchQueue.main.async {
                    self.getFiles()
                }
            }).store(in: &subscribers)
    }
}
