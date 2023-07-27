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
    }
    
    func getServersList() {
            
            self.appModel.vaultManager.tellaData.servers.sink { result in
                
            } receiveValue: { serverArray in
                self.serverDataItemArray.removeAll()
                if !serverArray.isEmpty {
                    // here i group all the tella servers in one array and the third party services in diferents arrays
                    let thirdPartyConnections = serverArray.filter { $0.serverType != 0 }
                    let tellaUploadServers = serverArray.filter { $0.serverType == 0 } // server type 0 => .tella
                    if !thirdPartyConnections.isEmpty {
                        self.serverDataItemArray.append(contentsOf: thirdPartyConnections.map { ServerDataItem(servers: [$0], serverType: mapServerTypeFromInt($0.serverType) )})
                    }
                    if !tellaUploadServers.isEmpty {
                        self.serverDataItemArray.append(ServerDataItem(servers: tellaUploadServers, serverType: mapServerTypeFromInt(0)))
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
