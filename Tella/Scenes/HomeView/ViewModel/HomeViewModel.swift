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
        listenToShouldReloadFiles()
    }
    func getServersList() {
        //        self.appModel.tellaData?.servers.sink { result in
        //
        //        } receiveValue: { serverArray in
        //            self.serverDataItemArray.removeAll()
        //            if !serverArray.isEmpty {
        //
        //                var serverConnections: [ServerConnectionType: [Server]] = [:]
        //
        //                for server in serverArray {
        //                    guard let serverType = server.serverType else { continue }
        //                    serverConnections[serverType, default: []].append(server)
        //                }
        //
        //                for (serverType, servers) in serverConnections {
        //                    self.serverDataItemArray.append(ServerDataItem(servers: servers, serverType: serverType ))
        //                }
        //            }
        //        }.store(in: &subscribers)
        if self.appModel.tellaData?.shouldReloadServers == true {
            print("App should reload the servers")
            self.serverDataItemArray.removeAll()
            if self.appModel.tellaData?.servers.isEmpty == true {
                
                var serverConnections: [ServerConnectionType: [Server]] = [:]
                let serverArray = self.appModel.tellaData?.servers ?? []
                for server in serverArray {
                    guard let serverType = server.serverType else { continue }
                    serverConnections[serverType, default: []].append(server)
                }
                
                for (serverType, servers) in serverConnections {
                    self.serverDataItemArray.append(ServerDataItem(servers: servers, serverType: serverType ))
                }
                
            }else {
                print("App should not reload the servers")
            }
        }
    }
        
        func getFiles()   {
            recentFiles = appModel.vaultFilesManager?.getRecentVaultFiles() ?? []
            hasRecentFile = recentFiles.count > 0
        }
        
        func deleteAllVaultFiles()   {
            appModel.vaultFilesManager?.deleteAllVaultFiles()
        }
        
        func deleteAllServersConnection()   {
            appModel.tellaData?.deleteAllServers()
        }
        
        private func listenToShouldReloadFiles() {
            self.appModel.vaultFilesManager?.shouldReloadFiles
                .sink(receiveValue: { shouldReloadVaultFiles in
                    DispatchQueue.main.async {
                        self.getFiles()
                    }
                }).store(in: &subscribers)
        }
    }
