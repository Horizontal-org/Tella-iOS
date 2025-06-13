//
//  UwaziSelectFileComponent.swift
//  Tella
//
//  Created by Gustavo on 24/10/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct UwaziSelectFileComponent: View {
    let title: String

    var body: some View {
        HStack {
            Image("uwazi.add-files")
                .padding(.vertical, 20)
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 16)
    }
}

struct UwaziFileSelector_Previews: PreviewProvider {
    static var previews: some View {
        UwaziSelectFileComponent(title: "Title")
    }
}
