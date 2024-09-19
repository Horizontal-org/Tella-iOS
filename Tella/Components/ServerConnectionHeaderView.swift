//
//  ServerConnectionHeaderView.swift
//  Tella
//
//  Created by gus valbuena on 5/29/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ServerConnectionHeaderView: View {
    var title: String
    var subtitle: String
    var imageIconName: String
    var body: some View {
        VStack(spacing: 8) {
            Image(imageIconName)
                .padding(.bottom, 16)
            Text(title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(.horizontal, 20)
    }
}

#Preview {
    ServerConnectionHeaderView(title: "title", subtitle: "subtitle", imageIconName: "gdrive.icon")
}
