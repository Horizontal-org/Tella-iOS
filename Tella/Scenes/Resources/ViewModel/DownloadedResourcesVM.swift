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
    @Published var downloadedResources: [DownloadedResourceCardViewModel] = []
    
    init(mainAppModel: MainAppModel) {
        self.appModel = mainAppModel
        fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() {
        downloadedResources = ResourceService().getDownloadedResources(from: appModel)
    }
    
    func deleteResource(resourceId: Int) -> Void {
        self.appModel.vaultManager.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        self.fetchDownloadedResources()
    }
    
    func openResource(fileName: String) {
//        let url = self.appModel.vaultManager.loadVaultFileToURL(file: VaultFileDB)
    }
}
