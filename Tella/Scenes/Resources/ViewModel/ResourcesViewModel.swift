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
    @Published var availableResources: [AvailableResourcesList] = []
    @Published var downloadedResources: [DownloadedResourcesList] = []
    @Published var isLoadingList: Bool = false
    private var servers: [TellaServer] = []
    private var cancellables: Set<AnyCancellable> = []
    
    var onShowResourceBottomSheet: ((String, String) -> Void)?

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
        [AvailableResourcesList], APIError
    > {
        // Logic to fetch available resources
        let resourceRepository = ResourceRepository()
        let publishers = self.servers.map { server in
            resourceRepository.getResourcesByProject(server: server)
                .map { response in
                    response.map { resource -> AvailableResourcesList in
                        AvailableResourcesList(
                            id: resource.id,
                            resourceCard: ResourceCardViewModel(
                                title: resource.title,
                                serverName: server.name ?? "",
                                type: .save,
                                action: {self.downloadResource(serverId: server.id ?? nil, resource: resource)}
                            ),
                            fileName: resource.fileName,
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

    func downloadResource(serverId: Int?, resource: Resource) {
        toggleIsLoadingResource(id: resource.id)
        guard let selectedServer = servers.first(where: { $0.id == serverId }) else {
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
                self.toggleIsLoadingResource(id: resource.id)
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
                toggleIsLoadingResource(id: resource.id)
                return
            }

            if resourceIsSaved {
                DispatchQueue.main.async {
                    self.getDownloadedResources()
                    self.availableResources.removeAll { $0.id == resource.id }
                }
            }
        } catch {
            debugLog(error)
        }
    }

    
    func getDownloadedResources() {
        self.downloadedResources = fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() -> [DownloadedResourcesList] {
        guard let resources = self.appModel.tellaData?.getResources() else {
            return []
        }

        return resources.map { resource in
            return DownloadedResourcesList(
                id: resource.id,
                externalId: resource.externalId,
                resourceCard: ResourceCardViewModel(
                    title: resource.title,
                    serverName: resource.server?.name ?? "",
                    type: .more,
                    action: { self.showResourceBottomSheet(resourceId: resource.id, resourceTitle: resource.title)}
                ),
                fileName: resource.fileName,
                size: resource.size,
                createdAt: resource.createdAt
            )
        }
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
    
    private func toggleIsLoadingResource(id: String) {
        if let index = self.availableResources.firstIndex(where: { $0.id == id }) {
            self.availableResources[index].isLoading = !self.availableResources[index].isLoading
            self.availableResources = self.availableResources.map { $0 }
        }
    }
    
    private func showResourceBottomSheet(resourceId: String, resourceTitle: String) {
        self.onShowResourceBottomSheet?(resourceId, resourceTitle)
    }
}
