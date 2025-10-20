//
//  HelpIcon.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct HelpIcon: View {
    let text: String
    @State private var show = false
    
    var body: some View {
        
        if #available(iOS 16.4, *) {
            Button {
                withAnimation(.spring(response: 0.2)) { show.toggle() }
            } label: {
                Image(.settingsHelpYellow).padding(8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $show, attachmentAnchor: .point(.top)) {
                helpText
                    .frame(maxWidth: 300, alignment: .leading)
                    .presentationCompactAdaptation(.popover)
            }
        } else {
            Button {
                withAnimation(.spring(response: 0.2)) { show.toggle() }
            } label: {
                Image(.settingsHelpYellow)
                    .padding(8)
            }
            .background(
                PopoverController(isPresented: $show, content: {
                    helpText
                })
            )
        }
    }
    
    private var helpText: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(.black)
            .padding(10)
    }
}

#Preview {
    HelpIcon(text: "Help text")
}
