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
            SectionTitle(text: LocalizableResources.resourcesAvailableTitle.localized)
            if availableResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesAvailableEmpty.localized)
            } else {
                SectionMessage(text: LocalizableResources.resourcesAvailableMsg.localized)
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
