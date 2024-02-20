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
    
    func deleteResource(resourceId: Int, vaultFileId: String) -> Void {
        self.appModel.vaultFilesManager?.deleteVaultFile(fileIds: [vaultFileId])
        self.appModel.vaultManager.tellaData?.deleteDownloadedResource(resourceId: resourceId)
        self.fetchDownloadedResources()
    }
    
    func openResource(vaultFileId: String) {
        guard let vaultFileDB = self.appModel.vaultFilesManager?.getVaultFile(id: vaultFileId) else { return }

        let url = self.appModel.vaultManager.loadVaultFileToURL(file: vaultFileDB)
        self.pdfFile = url
        self.isOpenFile = true
    }
}
