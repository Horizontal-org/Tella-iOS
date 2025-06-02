//
//  TextView.swift
//  Tella
//
//  Created by Gustavo on 17/08/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TextView: View {
    var content: String
    var size: CGFloat
    var body: some View {
        Text(content)
            .font(.custom(Styles.Fonts.regularFontName, size: CGFloat(size)))
            .foregroundColor(.white)
            .lineSpacing(7)
            .multilineTextAlignment(.center)
            .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(content: "some text", size: 18)
    }
}
