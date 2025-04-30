//
//  UwaziEntityButtonView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

// TODO: Did not use the TellaButtonView because the button content need to be different rather than just a text. Maybe Modify TellaButtonView later.
struct UwaziEntityButtonView<Content:View> : View {
    let content: Content
    var action : (() -> ())?

    init( action: (() -> Void)? = nil,
         @ViewBuilder content: () ->  Content) {
        self.action = action
        self.content = content()
    }
    var body: some View {
        Button {
            if action != nil {
                action?()
            }
        } label: {
            HStack {
                content
                Spacer()
            }
        }
        .cornerRadius(15)
        .buttonStyle(TellaButtonStyle(buttonStyle: ClearButtonStyle(), isValid: true))
    }
}
