//
//  UwaziEntitySubTitleView.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
