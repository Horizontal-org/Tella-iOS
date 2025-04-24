//
//  ConfirmPasswordErrorView.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ConfirmPasswordErrorView : View {
    var errorMessage : String
    
    var body: some View {
        Text(errorMessage)
            .foregroundColor(Color.black)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
            .background(Color(UIColor(hexValue: 0xE8E8EC)))
            .cornerRadius(5)
            .padding(EdgeInsets(top: 0, leading:10, bottom: 0, trailing: 10))
    }
}

struct ConfirmPasswordErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmPasswordErrorView(errorMessage: "Error")
    }
}
