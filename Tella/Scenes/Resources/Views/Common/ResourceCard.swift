//
//  ResourceCard.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourceCardView: View {
    var isLoading: Bool
    var resourceCard: ResourceCardViewModel
    
    var body: some View {
        CardFrameView(padding: EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0) ) {
            VStack(spacing: 0) {
                HStack {
                    Image("resources.pdf")
                        .padding()
                    ConnectionCardDetails(title: resourceCard.title, subtitle: resourceCard.serverName)
                    Spacer()
                    ZStack {
                        if(!isLoading) {
                            ImageButtonView(imageName: resourceCard.type.imageName, action: resourceCard.action)
                        } else {
                            CircularActivityIndicatory(isTransparent: true)
                        }
                    }.frame(width: 50)
                }.padding(.all, 8)
            }
        }
    }
}

#Preview {
    ResourceCardView(isLoading: false, resourceCard: ResourceCardViewModel(resource: Resource(id: "1231", title: "title", fileName: "filename"), serverName: "serverName", type: .more, action: {}))
}
