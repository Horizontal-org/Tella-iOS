//
//  UwaziEntitySubtitleView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziEntitySubtitleView: View {
    var subTitle: String
    var body: some View {
        Text(subTitle)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .foregroundColor(Color.white.opacity(0.8))
    }
}
struct UwaziEntitySubtitleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
                .ignoresSafeArea()
            UwaziEntitySubtitleView(subTitle: "Hello")
        }
    }
}
