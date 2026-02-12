//
//  LinkView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct LinkView: View {
    var url: String
    var text: String
    
    var body: some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                Text(text)
                    .foregroundColor(Styles.Colors.yellow)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
            }
        }
    }
}

#Preview {
    LinkView(url: TellaUrls.appLock, text: "Learn more")
}
