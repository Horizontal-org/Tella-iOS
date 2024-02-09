//
//  DownloadedResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DownloadedResourcesVM : ObservableObject {
    @Published var downloadedResources: [ResourceCardViewModel] = []
    init() {
        self.downloadedResources = getDownloadedResources()
    }
    
    func getDownloadedResources () -> [ResourceCardViewModel] {
        return ListOfDownloadedResources.map({ resource in
            ResourceCardViewModel(
                id: resource.id,
                title: resource.title,
                fileName: resource.fileName,
                serverName: "CLEEN Foundation" //change to the real server name
            )
            
        })
    }
}
