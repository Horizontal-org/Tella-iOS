//
//  AvailableResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation

class AvailableResourcesVM: ObservableObject {
    @Published var availableResources: [ResourceCardViewModel] = []
    @Published var isLoading: Bool = false
    @Published var servers: [TellaServer] = []
    private var cancellables: Set<AnyCancellable> = []
    init(mainAppModel: MainAppModel) {
        self.servers = mainAppModel.vaultManager.tellaData?.tellaServers.value ?? []
        
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
                                serverName: res.name
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
}

