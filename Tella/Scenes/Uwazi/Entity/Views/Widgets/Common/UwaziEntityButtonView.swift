//
//  UwaziEntityButton.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: Did not use the TellaButtonView because the button content need to be different rather than just a text. Maybe Modify TellaButtonView later.
struct UwaziEntityButtonView<Content:View> : View {
    var buttonType : ButtonType = .clear
    let content: Content
    var action : (() -> ())?
    var buttonStyle: TellaButtonStyleProtocol = ClearButtonStyle()

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
        .buttonStyle(TellaButtonStyle(buttonStyle: buttonStyle, isValid: true))
    }
}
