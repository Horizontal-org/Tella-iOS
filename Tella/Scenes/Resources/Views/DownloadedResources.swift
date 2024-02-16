//
//  DownloadedResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DownloadedResources: View {
    @ObservedObject var viewModel: DownloadedResourcesVM
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesDownloadedTitle.localized)
            if viewModel.downloadedResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesDownloadedEmpty.localized)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.downloadedResources) { resource in
                            ResourceCard(title: resource.title,
                                         serverName: resource.serverName,
                                         rightButtonImage: "reports.more",
                                         rightButtonAction: {})
                        }
                    }
                }.frame(maxHeight: CGFloat(viewModel.downloadedResources.count) * 90)
            }
        }.padding(.bottom, 24)
    }
}

#Preview {
    DownloadedResources(viewModel: DownloadedResourcesVM(mainAppModel: MainAppModel.stub()))
}
