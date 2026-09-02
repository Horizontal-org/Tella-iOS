//
//  MoreButtonView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ImageButtonView: View {
    var imageName : ImageResource
    var action : () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(imageName)
                .padding()
        }
    }
}

#Preview {
    ImageButtonView(imageName: .templateAdd, action: {})
}
