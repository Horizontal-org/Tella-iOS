//
//  UwaziEntityTitleView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziEntityTitleView: View {
    var title: String
    @State var isRequired: Bool
    var body: some View {
        Group {
            HStack {
                Text(title)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white)
                if isRequired {
                    Text("*")
                        .font(Font.custom(Styles.Fonts.boldFontName, size: 14))
                        .kerning(0.5)
                        .foregroundColor(Styles.Colors.yellow)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }

    }
}

struct UwaziEntityTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
                .ignoresSafeArea()
            UwaziEntityTitleView(title: "Hello", isRequired: true)
        }

    }
}
