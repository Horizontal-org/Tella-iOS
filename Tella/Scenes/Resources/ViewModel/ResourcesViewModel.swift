//
//  ResourcesViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class ResourcesViewModel: ObservableObject {
    private var mainAppModel: MainAppModel
    @Published var availableResources: [ResourceCardViewModel] = []
    @Published var downloadedResources: [ResourceCardViewModel] = []
    @Published var isLoadingList: Bool = false
    private var servers: [TellaServer] = []
    private var cancellables: Set<AnyCancellable> = []
    
    var onShowResourceBottomSheet: (() -> Void)?
    var selectedResource: DownloadedResource?

    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.servers = mainAppModel.tellaData?.getTellaServers() ?? []
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
                    self.handleCompletionForAvailableResources(completion)
                },
                receiveValue: { resources in
                    self.handleReceiveValueForAvailableResource(resources)
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
                            resource: resource,
                            serverName: server.name ?? "",
                            type: .save,
                            action: {self.downloadResource(serverId: server.id ?? nil, resource: resource)}
                        )
                    }
                }
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.flatMap { $0 } } 
            .eraseToAnyPublisher()
    }
    
    func handleCompletionForAvailableResources(_ completion: Subscribers.Completion<APIError>) {
        switch completion {
        case .failure( let error):
            switch error {
            case .noInternetConnection:
                Toast.displayToast(message: error.errorMessage)
            default:
                Toast.displayToast(message: LocalizableResources.resourcesAvailableErrorMsg.localized)
            }
        default:
            break
        }
        self.isLoadingList = false
    }
    
    func handleReceiveValueForAvailableResource(_ resources: [ResourceCardViewModel]) {
        self.isLoadingList = false
        let downloadedIds = Set(self.downloadedResources.map { $0.externalId })
        let newResources = resources.filter { !downloadedIds.contains($0.id) }
        self.availableResources.append(contentsOf: newResources)
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
                self.handleDownloadResourceError(error, resource)
            }
        }
    }
    
    func handleDownloadResourceError(_ error: APIError, _ resource: Resource) {
        switch error {
        case .noInternetConnection:
            debugLog("Error downloading file: \(error)")
            Toast.displayToast(message: error.errorMessage)
        default:
            debugLog("Error downloading file: \(error)")
            Toast.displayToast(message: error.localizedDescription)
        }
        self.toggleIsLoadingResource(id: resource.id)
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
            guard let resourceIsSaved = try self.mainAppModel.tellaData?.addResource(resource: resource, serverId: serverId, data: data) else {
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
    
    func fetchDownloadedResources() -> [ResourceCardViewModel] {
        guard let resources = self.mainAppModel.tellaData?.getResources() else {
            return []
        }

        return resources.map { resource in
            return ResourceCardViewModel(
                resource: resource,
                type: .more,
                action: { self.showResourceBottomSheet(resource: resource)},
                onTap: { self.selectResource(resource: resource)}
            )
        }
    }
    
    func deleteResource(resourceId: String) -> Void {
        let result = self.mainAppModel.tellaData?.deleteDownloadedResource(resourceId: resourceId)
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
    
    func openResource() -> URL? {
        guard let url = self.mainAppModel.vaultManager.loadFileToURL(fileName: selectedResource?.title ?? "", fileExtension: "pdf", identifier: selectedResource?.id ?? "") else { return nil }
        return url
    }
    
    private func toggleIsLoadingResource(id: String) {
        if let index = self.availableResources.firstIndex(where: { $0.id == id }) {
            self.availableResources[index].isLoading = !self.availableResources[index].isLoading
            self.availableResources = self.availableResources.map { $0 }
        }
    }
    
    private func showResourceBottomSheet(resource: DownloadedResource) {
        self.selectedResource = resource
        self.onShowResourceBottomSheet?()
    }
    
    private func selectResource(resource: DownloadedResource) {
        self.selectedResource = resource
    }
}

extension ResourcesViewModel {
    static func stub() -> ResourcesViewModel {
        return ResourcesViewModel(mainAppModel: MainAppModel.stub())
    }
}
