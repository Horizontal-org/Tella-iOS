//
//  UwaziEntityMandatoryTextView.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziEntityMandatoryTextView: View {
    var body: some View {
        Text("This field is mandatory.")
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
