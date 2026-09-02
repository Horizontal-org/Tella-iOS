//
//  CustomText.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CustomText: View {
    
    let text: String
    let style: TypographyStyle
    let alignment: TextAlignment
    let color: Color
    let fillsWidth: Bool
    
    init(_ text: String,
         style: TypographyStyle,
         alignment: TextAlignment = .leading,
         color: Color = .white,
         fillsWidth: Bool = false) {
        self.text = text
        self.style = style
        self.alignment = alignment
        self.color = color
        self.fillsWidth = fillsWidth
    }
    
    @ViewBuilder
    var body: some View {
        if fillsWidth {
            styledText
                .frame(maxWidth: .infinity, alignment: alignment.toAlignment)
        } else {
            styledText
        }
    }
    
    private var styledText: some View {
        Text(text)
            .style(style)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(alignment)
    }
}

private extension TextAlignment {
    var toAlignment: Alignment {
        switch self {
        case .center: return .center
        case .trailing: return .trailing
        default: return .leading
        }
    }
}
