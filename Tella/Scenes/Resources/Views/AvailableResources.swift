//
//  AvailableResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AvailableResources: View {
    var availableResources : [ResourceCardViewModel]
    var body: some View {
        VStack {
            SectionTitle(text: "Available for download")
            if availableResources.isEmpty {
                SectionMessage(text: "There are no resources available for download from your Tella Web project(s). ")
            } else {
                SectionMessage(text: "These are the resources available for download from your Tella Web project(s).")
                ForEach(availableResources) { resource in
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

#Preview {
    AvailableResources(availableResources: [ResourceCardViewModel(id: "Resource", title: "title", serverName: "serverName")])
}
