//
//  ServerConnectedSuccessView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ServerConnectedSuccessView: View {
    var body: some View {
        
        VStack(spacing: .extraLarge) {
            Spacer()
            ImageTitleMessageView(content: ServerConnectedContent())
            Image(.checkedCircle)
            Spacer()
        }.padding(.horizontal, .medium)
    }
}

#Preview {
    ServerConnectedSuccessView()
}
