//
//  ResourcesViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class ResourcesViewModel: ObservableObject {
    private var appModel: MainAppModel
    @Published var availableResources: [ResourceCardViewModel] = []
    @Published var downloadedResources: [DownloadedResourceCardViewModel] = []
    @Published var isLoadingList: Bool = false
    @Published var isLoadingDownload: Bool = false
    private var servers: [TellaServer] = []
    private let resourceService: ResourceService
    private var cancellables: Set<AnyCancellable> = []

    init(
        mainAppModel: MainAppModel,
        resourceService: ResourceService = ResourceService()
    ) {
        self.appModel = mainAppModel
        self.servers = mainAppModel.tellaData?.tellaServers.value ?? []

        self.resourceService = resourceService
        self.getAvailableForDownloadResources()
        self.fetchDownloadedResources()
    }

    func getAvailableForDownloadResources() {
        self.isLoadingList = true
        self.availableResources = []

        resourceService.getAvailableResources(appModel: appModel, servers: servers)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isLoadingList = false
                        break
                    case .failure(let error):
                        self.isLoadingList = false
                        Toast.displayToast(message: LocalizableResources.resourcesAvailableErrorMsg.localized)
                        print("Error: \(error)")
                    }

                },
                receiveValue: { resources in
                    self.isLoadingList = false
                    resources.forEach { resource in
                        let isDownloaded = self.downloadedResources.contains(where: { $0.externalId == resource.id })

                        if(!isDownloaded) {
                            self.availableResources.append(resource)
                        }
                    }

                }
            ).store(in: &cancellables)
    }

    func downloadResource(serverName: String, resource: Resource) {
        self.isLoadingDownload = true
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
            let resourceId = try self.appModel.tellaData?.addResource(resource: resource, serverId: serverId)
            guard let save = self.appModel.vaultManager.save(data, vaultFileId: resourceId) else { return }
            
            if save {
                self.fetchDownloadedResources()
                self.availableResources.removeAll { $0.id == resource.id}
            }
            self.isLoadingDownload = false
        } catch {
            debugLog(error)
        }
    }
    
    func fetchDownloadedResources() {
        downloadedResources = ResourceService().getDownloadedResources(from: appModel)
    }
    
    func deleteResource(resourceId: String) -> Void {
        self.appModel.vaultManager.deleteVaultFile(filesIds: [resourceId])
        self.appModel.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        self.fetchDownloadedResources()
        self.getAvailableForDownloadResources()
    }
    
    func openResource(resourceId: String, fileName: String) -> URL? {
        guard let url = self.appModel.vaultManager.loadFileToURL(fileName: fileName, fileExtension: "pdf", identifier: resourceId) else { return nil }
        return url
    }
}
