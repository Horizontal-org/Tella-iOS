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
    @Published var recentFiles : [VaultFileDB] = []

    var hasRecentFile = false
    
    private var subscribers = Set<AnyCancellable>()
    
    var showingFilesTitle: Bool {
        return (hasRecentFile && appModel.settings.showRecentFiles) || !serverDataItemArray.isEmpty
    }
    init(appModel:MainAppModel) {
        self.appModel = appModel
        getServersList()
    }
    func getServersList() {            
        self.appModel.vaultManager.tellaData?.servers.sink { result in
            
        } receiveValue: { serverArray in
            self.serverDataItemArray.removeAll()
            if !serverArray.isEmpty {
                                // here i group all the tella servers in one array and the third party services in diferents arrays
                let uwaziConnections = serverArray.filter { $0.serverType == .uwazi }
                let tellaUploadServers = serverArray.filter { $0.serverType == .tella }
                if !uwaziConnections.isEmpty { self.serverDataItemArray.append(ServerDataItem(servers: uwaziConnections, serverType: .uwazi)) }
                if !tellaUploadServers.isEmpty { self.serverDataItemArray.append(ServerDataItem(servers: tellaUploadServers, serverType: .tella)) }

            }
        }.store(in: &subscribers)
    }
    
    func getFiles()   {
        recentFiles = appModel.vaultFilesManager?.getRecentVaultFiles() ?? []
        hasRecentFile = recentFiles.count > 0
    }

    func deleteAllVaultFiles()   {
        appModel.vaultFilesManager?.deleteAllVaultFiles()
    }
    
    func deleteAllServersConnection()   {
        appModel.vaultManager.tellaData?.deleteAllServers()
    }

}
