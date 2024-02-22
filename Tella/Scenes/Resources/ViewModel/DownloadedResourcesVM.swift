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
    @Published var pdfFile: URL? = nil
    @Published var isOpenFile: Bool = false
    
    init(mainAppModel: MainAppModel) {
        self.appModel = mainAppModel
        fetchDownloadedResources()
    }
    
    func fetchDownloadedResources() {
        downloadedResources = ResourceService().getDownloadedResources(from: appModel)
    }
    
    func deleteResource(resourceId: String) -> Void {
        self.appModel.vaultManager.deleteVaultFile(filesIds: [resourceId])
        self.appModel.vaultManager.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        self.fetchDownloadedResources()
    }
    
    func openResource(resourceId: String, fileName: String) {
        let url = self.appModel.vaultManager.loadFileToURL(fileName: fileName, fileExtension: "pdf", identifier: resourceId)
        
        self.pdfFile = url
        self.isOpenFile = true
    }
}
