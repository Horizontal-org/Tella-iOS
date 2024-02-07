//
//  AvailableResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class AvailableResourcesVM: ObservableObject {
    @Published var availableResources: [ResourceCardViewModel] = []
    @Published var isLoading: Bool = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        getAvailableForDownloadResources()
    }

    func getAvailableForDownloadResources() {
        self.isLoading = true
        // replace this with the real data
        let serverURL = "https://api.beta.web.tella-app.org"
        let projectIds = [
            "8a228ad7-73dc-458b-93c1-4814325768bb",
            "6df06a36-3a4b-4109-8bd5-f4bebd921850",
        ]

        ResourceRepository().getResourcesByProject(
            serverUrl: serverURL, projectIds: projectIds
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                // Handle completion if needed
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
                self.availableResources = resourcesArray
            }
        )
        .store(in: &cancellables)
    }
}
