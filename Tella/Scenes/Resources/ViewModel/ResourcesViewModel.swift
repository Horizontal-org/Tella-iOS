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
    @Published var isDownloading: Bool = false
    private var servers: [TellaServer] = []
    private var cancellables: Set<AnyCancellable> = []

    init(
        mainAppModel: MainAppModel
    ) {
        self.appModel = mainAppModel
        self.servers = mainAppModel.tellaData?.tellaServers.value ?? []

        self.getAvailableForDownloadResources()
        self.getDownloadedResources()
    }

    func getAvailableForDownloadResources() {
        self.isLoadingList = true
        self.availableResources = []

        fetchAvailableResources()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isLoadingList = false
                        break
                    case .failure( let error):
                        switch error {
                        case .noInternetConnection:
                            Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
                        default:
                            Toast.displayToast(message: LocalizableResources.resourcesAvailableErrorMsg.localized)
                        }
                        self.isLoadingList = false
                    }

                },
                receiveValue: { resources in
                    self.isLoadingList = false
                    let downloadedIds = Set(self.downloadedResources.map { $0.externalId })
                    let newResources = resources.filter { !downloadedIds.contains($0.id) }
                    self.availableResources.append(contentsOf: newResources)

                }
            ).store(in: &cancellables)
    }
    
    func fetchAvailableResources() -> AnyPublisher<
        [ResourceCardViewModel], APIError
    > {
        // Logic to fetch available resources
        let resourceRepository = ResourceRepository()
        let publishers = self.servers.map { server in
            resourceRepository.getResourcesByProject(server: server)
                .map { response in
                    response.map { resource -> ResourceCardViewModel in
                        ResourceCardViewModel(
                            id: resource.id,
                            title: resource.title,
                            fileName: resource.fileName,
                            serverName: server.name ?? "",
                            size: resource.size,
                            createdAt: resource.createdAt
                        )
                    }
                }
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.flatMap { $0 } } 
            .eraseToAnyPublisher()
    }

    func downloadResource(serverName: String, resource: Resource) {
        self.isDownloading = true
        guard let selectedServer = servers.first(where: { $0.name == serverName }) else {
            return
        }

        fetchResourceFromServer(server: selectedServer, resource: resource) {
            result in
            switch result {
            case .success(let data):
                self.saveToVault(data: data, resource: resource, serverId: selectedServer.id!)
            case .failure(let error):
                switch error {
                case .noInternetConnection:
                    debugLog("Error downloading file: \(error)")
                    Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
                default:
                    debugLog("Error downloading file: \(error)")
                    Toast.displayToast(message: error.localizedDescription)
                }
                self.isDownloading = false
            }
        }
    }
    

    func fetchResourceFromServer(
        server: TellaServer, resource: Resource,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let resourceRepository = ResourceRepository()
        resourceRepository.getResourceByFileName(
            server: server, fileName: resource.fileName
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { comp in
                if case .failure(let error) = comp {
                    completion(.failure(error))
                }
            },
            receiveValue: { data in
                completion(.success(data))
            }
        )
        .store(in: &cancellables)
    }
    
    private func saveToVault(data: Data, resource: Resource, serverId: Int) {
        do {
            guard let resourceIsSaved = try self.appModel.tellaData?.addResource(resource: resource, serverId: serverId, data: data) else {
                isDownloading = false
                return
            }

            if resourceIsSaved {
                DispatchQueue.main.async {
                    self.getDownloadedResources()
                    self.availableResources.removeAll { $0.id == resource.id }
                    self.isDownloading = false
                }
            }
        } catch {
            debugLog(error)
        }
    }

    
    func getDownloadedResources() {
        downloadedResources = fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() -> [DownloadedResourceCardViewModel] {
        guard let resources = self.appModel.tellaData?.getResources() else {
            return []
        }

        return resources.map { resource in
            return createResourceCardViewModel(resource: resource)
        }
    }

    private func createResourceCardViewModel(resource: DownloadedResource
    ) -> DownloadedResourceCardViewModel {
        let selectedServer = self.appModel.tellaData?.tellaServers.value.first {
            $0.id == resource.serverId
        }

        return DownloadedResourceCardViewModel(
            id: resource.id,
            externalId: resource.externalId,
            title: resource.title,
            fileName: resource.fileName,
            serverName: selectedServer?.name ?? "",
            size: resource.size,
            createdAt: resource.createdAt
        )
    }
    
    func deleteResource(resourceId: String) -> Void {
        let result = self.appModel.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        switch result {
        case .success(_):
            self.getDownloadedResources()
            self.getAvailableForDownloadResources()
        case .failure(let error):
            debugLog(error)
            Toast.displayToast(message: error.localizedDescription)
        default:
            break
        }
    }
    
    func openResource(resourceId: String, fileName: String) -> URL? {
        guard let url = self.appModel.vaultManager.loadFileToURL(fileName: fileName, fileExtension: "pdf", identifier: resourceId) else { return nil }
        return url
    }
}
