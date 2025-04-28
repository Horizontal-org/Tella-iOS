//
//  ConnectionEmptyView.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ConnectionEmptyView: View {
    
    var message: String
    var iconName: String

    var body: some View {
        VStack(alignment: .center, spacing: 22) {
            Image(iconName)
            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(EdgeInsets(top: 0, leading: 31, bottom: 0, trailing: 31))
    }
}

#Preview {
    ConnectionEmptyView(message: "You have no draft reports", iconName: "uwazi.empty")
}
