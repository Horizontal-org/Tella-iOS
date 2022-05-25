//
//  LockDescriptionView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockDescriptionView : View {
    
    var title : String
    var description : String
    var alignement : TextAlignment = .center

    var body: some View {
        VStack {
            Text(title)
                .font(.custom(Styles.Fonts.boldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 20)
            Text(description)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .lineSpacing(7)
                .multilineTextAlignment(alignement)
        }
        .padding(EdgeInsets(top: 0, leading: 46, bottom: 0, trailing: 46))
    }
}

struct LockDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        LockDescriptionView(title: Localizable.Lock.lockPasswordSetSubhead,
                            description: Localizable.Lock.lockPasswordSetExpl)
    }
}
