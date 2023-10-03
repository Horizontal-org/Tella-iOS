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
                self.serverDataItemArray.append(ServerDataItem(servers: serverArray, serverType: .tellaUpload))
            }
        }.store(in: &subscribers)
    }
    
    func getFiles()   {
        recentFiles = appModel.vaultManager.getRecentVaultFiles()
        hasRecentFile = recentFiles.count > 0
    }

    func deleteAllVaultFiles()   {
        appModel.deleteAllVaultFiles()
    }
    
    func deleteAllServersConnection()   {
        do {
            try appModel.vaultManager.tellaData?.deleteAllServers()
        } catch {
            print("Error deleting all servers connections")
        }
    }

}
