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
            SectionTitle(text: "Downloaded")
            if downloadedResources.isEmpty {
                SectionMessage(text: "You have not downloaded any resources. Tap on the “download” icon next to each resource below to get started.")
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
