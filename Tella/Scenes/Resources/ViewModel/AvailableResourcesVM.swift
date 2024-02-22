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
    @Published var downloadedResourcesVM: DownloadedResourcesVM?
    @Published var isLoading: Bool = false
    @Published var servers: [TellaServer] = []
    private let resourceService: ResourceService
    private var cancellables: Set<AnyCancellable> = []

    init(
        mainAppModel: MainAppModel, downloadedVM: DownloadedResourcesVM? = nil,
        resourceService: ResourceService = ResourceService()
    ) {
        self.appModel = mainAppModel
        self.servers = mainAppModel.vaultManager.tellaData?.tellaServers.value ?? []
        self.downloadedResourcesVM = downloadedVM
        self.resourceService = resourceService
        self.getAvailableForDownloadResources()
        
        self.listenDownloadDeletion()
    }

    func getAvailableForDownloadResources() {
        self.isLoading = true
        self.availableResources = []

        resourceService.getAvailableResources(appModel: appModel, servers: servers)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isLoading = false
                        break
                    case .failure(let error):
                        self.isLoading = false
                        Toast.displayToast(message: LocalizableResources.resourcesAvailableErrorMsg.localized)
                        print("Error: \(error)")
                    }

                },
                receiveValue: { resources in
                    resources.forEach { resource in
                        let isDownloaded = self.downloadedResourcesVM?.downloadedResources.contains(where: { $0.externalId == resource.id })
                        
                        if(!isDownloaded!) {
                            self.availableResources.append(resource)
                        }
                    }
                    self.isLoading = false

                }
            ).store(in: &cancellables)
    }

    func downloadResource(serverName: String, resource: Resource) {
        guard let selectedServer = servers.first(where: { $0.name == serverName }) else {
            return
        }

        resourceService.downloadResource(server: selectedServer, resource: resource) {
            result in
            switch result {
            case .success(let data):
                self.saveToVault(data: data, resource: resource, serverId: selectedServer.id!)
            case .failure(let error):
                print("Error downloading file: \(error)")
            }
        }
    }
    
    private func saveToVault(data: Data, resource: Resource, serverId: Int) {
        
        do {
            let resourceId = try self.appModel.vaultManager.tellaData?.addResource(resource: resource, serverId: serverId)
            guard let save = self.appModel.vaultManager.save(data, vaultFileId: resourceId) else { return }
            
            if save {
                self.downloadedResourcesVM?.fetchDownloadedResources()
                self.availableResources.removeAll { $0.id == resource.id}
            }
        } catch {
            debugLog(error)
        }
    }
    
    private func listenDownloadDeletion() {
        self.downloadedResourcesVM?.resourceDeleted
            .sink { [weak self] _ in
                self?.getAvailableForDownloadResources()
            }
            .store(in: &cancellables)
    }
}
