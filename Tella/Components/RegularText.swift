//
//  RegularText.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RegularText: View {
    
    var text: String
    var size: CGFloat = 14
    var color: Color = .white
    
    init(_ text: String, size: CGFloat = 14, color: Color = .white) {
        self.text = text
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(.custom(Styles.Fonts.regularFontName, size: size))
            .foregroundColor(color)
    }
    
}
