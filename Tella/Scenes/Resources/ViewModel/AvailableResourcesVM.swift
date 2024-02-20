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
        getAvailableForDownloadResources()
    }

    func getAvailableForDownloadResources() {
        self.isLoading = true

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
                    self.availableResources.append(contentsOf: resources)
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
        guard let tempUrl = self.appModel.vaultFilesManager!.vaultManager?.createTempFileURL(fileName: resource.fileName, pathExtension: "pdf") else {
            return
        }
        do {
            try data.write(to: tempUrl)
        } catch {
            print("Error writing file to temporary URL")
            return
        }
        
        self.appModel.vaultFilesManager!.addVaultFile(filePaths: [tempUrl], parentId: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { result in
                switch result {
                case .fileAdded(let vaultFiles):
                    guard let vaultFile = vaultFiles.first else { return  }
                    self.insertResources(vaultFile: vaultFile, resource: resource, serverId: serverId)
                case .importProgress(_):
                    break
                }
            }).store(in: &cancellables)
    }
    
    private func insertResources(vaultFile: VaultFileDB, resource: Resource, serverId: Int) -> Void {
        dump(vaultFile.id)
        self.appModel.vaultManager.tellaData?.addResource(
            resource: resource, serverId: serverId, vaultFileId: vaultFile.id!)
        self.downloadedResourcesVM?.fetchDownloadedResources()
    }
}
