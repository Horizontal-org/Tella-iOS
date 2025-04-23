//
//  UwaziSuccessView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/27/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziSuccessView: View {
    var body: some View {
        ContainerView {
            VStack(spacing: 10) {
                Spacer()
                TopServerView(title: LocalizableSettings.UwaziSuccess.localized)
                Text(LocalizableSettings.UwaziSuccessMessage.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 53)
                Image("settings.checked-circle")
                Spacer()
                NavigationBottomView<AnyView>(shouldActivateNext: .constant(true),
                                        nextButtonAction: .action,
                                        shouldHideNext: false,
                                        shouldHideBack: true,
                                        nextAction: {
                    self.popTo(ViewClassType.serversListView)
                    
                })
            }.padding(.leading, 23)
                .padding(.trailing, 23)

        }.navigationBarHidden(true)
    }
}

struct UwaziSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziSuccessView()
    }
}
