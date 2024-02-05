//
//  DownloadedResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DownloadedResources: View {
    var downloadedResources: [ResourceCardViewModel]
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesDownloadedTitle.localized)
            if downloadedResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesDownloadedEmpty.localized)
            } else {
                ForEach(downloadedResources) { resource in
                    ResourceCard(title: resource.title,
                                 serverName: resource.serverName,
                                 rightButtonImage: "reports.more",
                                 rightButtonAction: {})
                }
            }
        }.padding(.bottom, 12)
    }
}

#Preview {
    DownloadedResources(downloadedResources: [ResourceCardViewModel(id: "Resource", title: "title", serverName: "serverName")])
}
