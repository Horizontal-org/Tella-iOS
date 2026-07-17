//
//  LockDescriptionView.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
        LockDescriptionView(title: LocalizableLock.lockPasswordSetSubhead.localized,
                            description: LocalizableLock.lockPasswordSetExpl1.localized.bulleted().addline
                            + LocalizableLock.lockPasswordSetExpl2.localized.bulleted().addline
                            + LocalizableLock.lockPasswordSetExpl3.localized.bulleted())
    }
}
