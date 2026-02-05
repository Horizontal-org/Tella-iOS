//
//  CustomAttributedText.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/2/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CustomAttributedText: View {
    
    private let text: AnyView
    let style: TypographyStyle
    let alignment: TextAlignment
    let color: Color
    
    init(_ attributedText: NSAttributedString,
         style: TypographyStyle,
         alignment: TextAlignment = .leading,
         color: Color = .white) {
        if #available(iOS 15, *) {
            self.text = AnyView(
                Text(AttributedString(attributedText))
            )
        } else {
            self.text = AnyView(
                AttributedLabel(attributedText: attributedText)
            )
        }
        self.style = style
        self.alignment = alignment
        self.color = color
    }
    
    
    var body: some View {
        text
            .style(style)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(alignment)
    }
}
