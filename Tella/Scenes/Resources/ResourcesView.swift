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
                    DownloadedResources()
                        .environmentObject(resourcesViewModel)
                    
                    // available for download
                    AvailableResources()
                        .environmentObject(resourcesViewModel)
                    
                    Spacer()
                }.padding(.all, 18)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            LeadingTitleToolbar(title: LocalizableResources.resourcesServerTitle.localized)
            ReloadButton(action: {
                resourcesViewModel.getAvailableForDownloadResources()
            })
        }
    }
}

#Preview {
    ResourcesView(mainAppModel: MainAppModel.stub())
}
