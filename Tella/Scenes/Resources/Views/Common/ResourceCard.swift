//
//  ResourceCard.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourceCard: View {
    var isLoading: Bool
    var title: String
    var serverName: String
    var type: ResourceCardType
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("resources.pdf")
                    .padding()
                ConnectionCardDetail(title: title, subtitle: serverName)
                Spacer()
                ImageButtonView(imageName: type.imageName, action: action).disabled(isLoading)
            }.padding(.all, 8)
        }
        .customCardStyle()
    }
}

#Preview {
    ResourceCard(isLoading: false, title: "How to submit a form", serverName: "CLEEN Foundation",type: .save, action: {})
}
