//
//  AvailableResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AvailableResources: View {
    @ObservedObject var viewModel: AvailableResourcesVM
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesAvailableTitle.localized)
            if viewModel.isLoading {
                CircularActivityIndicatory()
            }
            else if viewModel.availableResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesAvailableEmpty.localized)
            } else {
                VStack {
                    SectionMessage(text: LocalizableResources.resourcesAvailableMsg.localized)
                }
                ScrollView {
                    ForEach(viewModel.availableResources) { resource in
                        ResourceCard(
                            title: resource.title,
                            serverName: resource.serverName,
                            rightButtonImage: "save-icon",
                            rightButtonAction: {}
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    AvailableResources(viewModel: AvailableResourcesVM())
}
