//
//  BottomButtonActionView.swift
//  Tella
//
//  Created on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct BottomButtonActionView: View {
    let title: String
    let isValid: Bool
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            UIApplication.shared.endEditing()
            action?()
        } label: {
            Text(title)
        }
        .font(.custom(Styles.Fonts.lightFontName, size: 16))
        .foregroundColor(isValid ? Color.white : Color.gray)
        .padding(EdgeInsets(top: 17, leading: 34, bottom: 45, trailing: 34))
        .disabled(!isValid)
        .frame(height: .bottomButtonHeight)

    }
}
