//
//  UwaziEntityMandatoryTextView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziEntityMandatoryTextView: View {
    var body: some View {
        Text(LocalizableUwazi.uwaziEntityMandatoryExpl.localized)
            .font(Font.custom(Styles.Fonts.regularFontName, size: 12))
            .foregroundColor(Styles.Colors.yellow)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 4)
    }
}

struct UwaziEntityMandatoryTextView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziEntityMandatoryTextView()
    }
}
