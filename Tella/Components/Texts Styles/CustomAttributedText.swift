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
    
    private let attributedText: NSAttributedString
    let style: TypographyStyle
    let alignment: TextAlignment
    let color: Color
    
    init(_ attributedText: NSAttributedString,
         style: TypographyStyle,
         alignment: TextAlignment = .leading,
         color: Color = .white) {
        self.attributedText = attributedText
        self.style = style
        self.alignment = alignment
        self.color = color
    }
    
    
    var body: some View {
        Text(AttributedString(attributedText))
            .style(style)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(alignment)
    }
}
