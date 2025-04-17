//
//  CustomText.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CustomText: View {
    
    let text: String
    let style: TypographyStyle
    let alignment: TextAlignment
    let color: Color
    
    init(_ text: String,
         style: TypographyStyle = .body1Font,
         alignment: TextAlignment = .leading,
         color: Color = .white) {
        self.text = text
        self.style = style
        self.alignment = alignment
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(style.font)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(alignment)
    }
}
