//
//  AvailableResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class AvailableResourcesVM : ObservableObject {
    @Published var availableResources: [ResourceCardViewModel] = []
    
    init() {
        self.availableResources = getAvailableForDownloadResources()
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
