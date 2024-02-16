//
//  ResourceService.swift
//  Tella
//
//  Created by gus valbuena on 2/16/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourceService {
    func getDownloadedResources(from appModel: MainAppModel) -> [ResourceCardViewModel] {
        guard let resources = appModel.vaultManager.tellaData?.getResources() else {
            return []
        }
        
        return resources.map { resource in
            dump(resource.id)
            return createResourceCardViewModel(from: resource, in: appModel)
        }
    }
    
    private func createResourceCardViewModel(from resource: DownloadedResource, in appModel: MainAppModel) -> ResourceCardViewModel {
        let selectedServer = appModel.vaultManager.tellaData?.tellaServers.value.first { $0.id == resource.serverId }
        
        return ResourceCardViewModel(
            id: resource.externalId,
            title: resource.title,
            fileName: resource.fileName,
            serverName: selectedServer?.name ?? "",
            size: resource.size,
            createdAt: resource.createdAt
        )
    }
}
