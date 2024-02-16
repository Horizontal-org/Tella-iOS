//
//  AvailableResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation
import Combine

class AvailableResourcesVM: ObservableObject {
    @Published var appModel: MainAppModel
    @Published var availableResources: [ResourceCardViewModel] = []
    @Published var downloadedResourcesVM : DownloadedResourcesVM?
    @Published var isLoading: Bool = false
    @Published var servers: [TellaServer] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(mainAppModel: MainAppModel, downloadedVM: DownloadedResourcesVM? = nil) {
        self.appModel = mainAppModel
        self.servers = mainAppModel.vaultManager.tellaData?.tellaServers.value ?? []
        self.downloadedResourcesVM = downloadedVM
        getAvailableForDownloadResources()
    }

    func getAvailableForDownloadResources() {
        self.isLoading = true
        
        let resourceRepository = ResourceRepository()
        servers.forEach { server in
            resourceRepository.getResourcesByProject(
                server: server
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isLoading = false
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                },
                receiveValue: { response in
                    let resourcesArray = response.flatMap { res in
                        res.resources.map { resource in
                            ResourceCardViewModel(
                                id: resource.id,
                                title: resource.title,
                                fileName: resource.fileName,
                                serverName: res.name,
                                size: resource.size,
                                createdAt: resource.createdAt
                            )
                        }
                    }
                    self.availableResources.append(contentsOf: resourcesArray)
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
        }
    }
    
    func downloadResource(serverName: String, resource: Resource) -> Void {
        let selectedServer = self.servers.first(where: {$0.name == serverName})
        
        ResourceRepository().getResourceByFileName(server: selectedServer!, fileName: resource.fileName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error downloading file: \(error)")
                }
            }, receiveValue: { data in
                dump(data) //save this data in the device
            })
            .store(in: &cancellables)
        
        self.appModel.vaultManager.tellaData?.addResource(resource: resource, serverId: (selectedServer?.id!)!)
        
        self.downloadedResourcesVM?.fetchDownloadedResources()
    }
}
