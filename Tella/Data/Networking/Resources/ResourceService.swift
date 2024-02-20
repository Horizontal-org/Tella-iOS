//
//  ResourceService.swift
//  Tella
//
//  Created by gus valbuena on 2/16/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class ResourceService {
    private var cancellables: Set<AnyCancellable> = []
    func getDownloadedResources(from appModel: MainAppModel) -> [DownloadedResourceCardViewModel] {
        guard let resources = appModel.vaultManager.tellaData?.getResources() else {
            return []
        }

        return resources.map { resource in
            return createResourceCardViewModel(from: resource, in: appModel)
        }
    }

    private func createResourceCardViewModel(
        from resource: DownloadedResource, in appModel: MainAppModel
    ) -> DownloadedResourceCardViewModel {
        let selectedServer = appModel.vaultManager.tellaData?.tellaServers.value.first {
            $0.id == resource.serverId
        }

        return DownloadedResourceCardViewModel(
            id: resource.id!,
            externalId: resource.externalId,
            title: resource.title,
            fileName: resource.fileName,
            serverName: selectedServer?.name ?? "",
            size: resource.size,
            createdAt: resource.createdAt
        )
    }

    func getAvailableResources(appModel: MainAppModel, servers: [TellaServer]) -> AnyPublisher<
        [ResourceCardViewModel], APIError
    > {
        // Logic to fetch available resources
        let resourceRepository = ResourceRepository()
        let publishers = servers.map { server in
            resourceRepository.getResourcesByProject(server: server)
                .map { response in
                    response.flatMap { res in
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
                }
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.flatMap { $0 } }
            .eraseToAnyPublisher()
    }

    func downloadResource(
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
}
