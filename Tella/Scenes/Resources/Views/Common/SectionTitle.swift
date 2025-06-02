//
//  SectionTitle.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SectionTitle: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(.custom(Styles.Fonts.boldFontName, size: 14))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SectionTitle(text: "Hello")
}
