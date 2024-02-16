//
//  ResourcesView.swift
//  Tella
//
//  Created by gus valbuena on 1/31/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourcesView: View {
    @StateObject private var resourcesViewModel : ResourcesViewModel
    
    init(mainAppModel: MainAppModel) {
        _resourcesViewModel = StateObject(wrappedValue: ResourcesViewModel(mainAppModel: mainAppModel))
    }

    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    // Downloaded
                    DownloadedResources(viewModel: resourcesViewModel.downloadedResourcesVM)
                    
                    // available for download
                    AvailableResources(viewModel: resourcesViewModel.availableResourcesVM)
                    
                    Spacer()
                }.padding(.all, 18)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            LeadingTitleToolbar(title: "Resources")
            ReloadButton(action: {
                resourcesViewModel.availableResourcesVM.getAvailableForDownloadResources()
            })
        }
    }
}

#Preview {
    ResourcesView(mainAppModel: MainAppModel.stub())
}
