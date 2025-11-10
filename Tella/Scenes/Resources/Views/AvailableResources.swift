//
//  AvailableResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct AvailableResources: View {
    var viewModel : ResourcesViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: LocalizableResources.resourcesAvailableTitle.localized)
            availableResourceContent
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
                        ResourceCardView(isLoading: resource.isLoading, resourceCard: resource)
                    }
                }
            }
        }
    }
}

#Preview {
    AvailableResources(viewModel: ResourcesViewModel.stub())
}
