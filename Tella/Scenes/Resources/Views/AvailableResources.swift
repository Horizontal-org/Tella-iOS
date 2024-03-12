//
//  AvailableResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AvailableResources: View {
    @EnvironmentObject var viewModel : ResourcesViewModel
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesAvailableTitle.localized)
            VStack {
                availableResourceContent
            }
        }
    }
    
    @ViewBuilder
    var availableResourceContent: some View {
        if viewModel.isLoadingList {
            loadingView
        }
        else if viewModel.availableResources.isEmpty {
            emptyStateView
        } else {
            resourceListView
        }
    }
    
    private var loadingView: some View {
        CircularActivityIndicatory(isTransparent: true)
    }
    
    private var emptyStateView: some View {
        SectionMessage(text: LocalizableResources.resourcesAvailableEmpty.localized)
    }
    
    private var resourceListView: some View {
        VStack {
            SectionMessage(text: LocalizableResources.resourcesAvailableMsg.localized)
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.availableResources) { resource in
                        resourceCard(resource: resource)
                    }
                }
            }
        }
    }
    
    private func resourceCard(resource: ResourceCardViewModel) -> some View {
        ResourceCard(
            isLoading: resource.isLoading,
            title: resource.title,
            serverName: resource.serverName,
            type: .save,
            action: {viewModel.downloadResource(serverName: resource.serverName, resource: Resource(
                id: resource.id, title: resource.title, fileName: resource.fileName, size: resource.size, createdAt: resource.createdAt
            ))}
        )
    }
}

#Preview {
    AvailableResources()
}
