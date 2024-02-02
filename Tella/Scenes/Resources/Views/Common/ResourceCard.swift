//
//  ResourceCard.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourceCard: View {
    var title: String
    var serverName: String
    var rightButtonImage: String
    var rightButtonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("resources.pdf")
                    .padding()
                ConnectionCardDetail(title: title, subtitle: serverName)
                Spacer()
                MoreButtonView(imageName: rightButtonImage, action: rightButtonAction)
            }.padding(.all, 8)
        }
        .customCardStyle()
    }
}

#Preview {
    ResourceCard(title: "How to submit a form", serverName: "CLEEN Foundation", rightButtonImage: "save-icon", rightButtonAction: {})
}
