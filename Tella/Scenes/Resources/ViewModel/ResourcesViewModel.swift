//
//  ResourcesViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourcesViewModel: ObservableObject {
    @Published var downloadedResources: [ResourceCardViewModel] = []
    @Published var availableResources: [ResourceCardViewModel] = []
    
    init() {
        self.downloadedResources = getDownloadedResources()
        self.availableResources = getAvailableForDownloadResources()
    }
    
    func getDownloadedResources () -> [ResourceCardViewModel] {
        return ListOfDownloadedResources.map({ resource in
            ResourceCardViewModel(
                id: resource.id,
                title: resource.title,
                serverName: "CLEEN Foundation" //change to the real server name
            )
            
        })
    }
    
    func getAvailableForDownloadResources () -> [ResourceCardViewModel] {
        return ListOfAvailableResources.map({ resource in
            ResourceCardViewModel(
                id: resource.id,
                title: resource.title,
                serverName: "CLEEN Foundation"
            )
        })
    }
}
