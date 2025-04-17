//
//  CardModifier.swift
//  Tella
//
//  Created by RIMA on 04.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    var backgroundColor: Color = .white.opacity(0.08)
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
    }
}

extension View {
    func cardModifier(cornerRadius: CGFloat = 16, padding: CGFloat = 16, backgroundColor: Color = .white.opacity(0.08)) -> some View {
        self.modifier(CardModifier(cornerRadius: cornerRadius, padding: padding, backgroundColor: backgroundColor))
    }
}
