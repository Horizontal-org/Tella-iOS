//
//  ResourcesViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourcesViewModel: ObservableObject {
    @Published var downloadedResourcesVM : DownloadedResourcesVM
    @Published var availableResourcesVM : AvailableResourcesVM
    
    init(mainAppModel: MainAppModel) {
        let downloadedVM = DownloadedResourcesVM(mainAppModel: mainAppModel)
        
        self.downloadedResourcesVM = downloadedVM
        self.availableResourcesVM = AvailableResourcesVM(mainAppModel: mainAppModel, downloadedVM: downloadedVM)
    }
}
