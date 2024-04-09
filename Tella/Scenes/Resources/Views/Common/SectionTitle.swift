//
//  SectionTitle.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SectionTitle: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(.custom(Styles.Fonts.boldFontName, size: 14))
            .fontWeight(.semibold)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SectionTitle(text: "Hello")
}
