//
//  PasswordTextFieldView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PasswordTextView : View {

    @Binding var fieldContent : String
    @Binding var isValid : Bool
    var shouldValidateField : Bool = true

    var disabled : Bool = false
    var onCommit : (() -> Void)? =  ({})
    
    var body: some View {
        Text(fieldContent)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .font(.custom(Styles.Fonts.regularFontName, size: 60))
            .foregroundColor(!isValid && shouldValidateField ? Styles.Colors.red : Styles.Colors.petrol)
            .lineLimit(1)
    }
}

struct PasswordTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextView(fieldContent: .constant("hg"),
                              isValid: .constant(true))
    }
}
