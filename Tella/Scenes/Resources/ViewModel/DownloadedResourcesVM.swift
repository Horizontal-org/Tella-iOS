//
//  DownloadedResourcesVM.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DownloadedResourcesVM : ObservableObject {
    @Published var appModel: MainAppModel
    @Published var downloadedResources: [DownloadedResourceCardViewModel] = []
    
    let resourceDeleted = PassthroughSubject<Void, Never>()
    
    init(mainAppModel: MainAppModel) {
        self.appModel = mainAppModel
        fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() {
        downloadedResources = ResourceService().getDownloadedResources(from: appModel)
    }
    
    func deleteResource(resourceId: String) -> Void {
        self.appModel.vaultManager.deleteVaultFile(filesIds: [resourceId])
        self.appModel.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        self.fetchDownloadedResources()
        resourceDeleted.send()
    }
    
    func openResource(resourceId: String, fileName: String) -> URL? {
        guard let url = self.appModel.vaultManager.loadFileToURL(fileName: fileName, fileExtension: "pdf", identifier: resourceId) else { return nil }
        return url
    }
}
