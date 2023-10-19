//
//  UwaziEntityMandatoryTextView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziEntityMandatoryTextView: View {
    var body: some View {
        Text(LocalizableUwazi.uwaziEntityMandatoryExpl.localized)
            .font(Font.custom(Styles.Fonts.boldFontName, size: 12))
            .foregroundColor(Styles.Colors.yellow)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct UwaziEntityMandatoryTextView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziEntityMandatoryTextView()
    }
}
