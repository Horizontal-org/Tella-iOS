//
//  BottomSheetTitleView.swift
//  Tella
//
//  Created by Gustavo on 11/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct BottomSheetTitleView: View {
    var title: String
    var description: String
    
    var body: some View {
        
        Text(title)
            .font(.custom(Styles.Fonts.boldFontName, size: 16))
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
        
        Spacer()
            .frame(height: 10)
        
        Text(description)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
    }
}

struct BottomSheetTitleView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetTitleView(title: "Some Title", description: "Some Description")
    }
}
