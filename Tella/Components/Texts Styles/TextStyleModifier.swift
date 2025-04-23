//
//  TextStyleModifier.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 22/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TextStyleModifier: ViewModifier {
    let style: TypographyStyle
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .font(.custom(style.name, size: style.fontSize))
                .lineSpacing(style.lineSpacing)
                .kerning(style.characterSpacing)
        } else {
            content
                .font(.custom(style.name, size: style.fontSize))
                .lineSpacing(style.lineSpacing)
        }
    }
}

extension View {
    func style(_ style: TypographyStyle) -> some View {
        self.modifier(TextStyleModifier(style: style))
    }
}
