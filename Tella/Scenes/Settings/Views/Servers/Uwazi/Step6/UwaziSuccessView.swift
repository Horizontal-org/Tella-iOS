//
//  UwaziSuccessView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/27/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
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
                BottomLockView<AnyView>(isValid: .constant(true),
                                        nextButtonAction: .action,
                                        shouldHideNext: false,
                                        shouldHideBack: true,
                                        nextAction: {
                    self.popTo(UIHostingController<Optional<ModifiedContent<ServersListView, _EnvironmentKeyWritingModifier<Optional<ServersViewModel>>>>>.self)
                })
            }.padding(.leading, 23)
                .padding(.trailing, 23)

        }
        .navigationBarBackButtonHidden(true)
    }
}

struct UwaziSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziSuccessView()
    }
}
