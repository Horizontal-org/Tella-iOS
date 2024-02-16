//
//  DownloadedResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DownloadedResourcesVM : ObservableObject {
    @Published var appModel: MainAppModel
    @Published var downloadedResources: [ResourceCardViewModel] = []
    
    init(mainAppModel: MainAppModel) {
        self.appModel = mainAppModel
        fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() {
        downloadedResources = ResourceService().getDownloadedResources(from: appModel)
    }
}
