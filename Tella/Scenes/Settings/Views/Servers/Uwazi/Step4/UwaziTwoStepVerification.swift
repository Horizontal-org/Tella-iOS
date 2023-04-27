//
//  UwaziTwoStepVerification.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziTwoStepVerification: View {
    @State var code = ""
    @State var validCode = false
    @State var shouldShowLoginError = false
    @State var codeErrorMessage = ""
    @State var validCredentials = true
    @State var validPassword = true
    @State var showLanguageView = false

    @EnvironmentObject var serverViewModel : ServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel

    var body: some View {
        ContainerView {
            VStack {
                VStack(spacing: 10) {
                    Spacer()
                    TopServerView(title: LocalizableSettings.UwaziTwoStepTitle.localized)
                    Text(LocalizableSettings.UwaziTwoStepMessage.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(height: 15)
                    TextfieldView(fieldContent: $code,
                                  isValid: $validCode,
                                  shouldShowError: $shouldShowLoginError,
                                  errorMessage: codeErrorMessage,
                                  fieldType: .code,
                                  placeholder : LocalizableSettings.UwaziAuthenticationPlaceholder.localized)
                    .frame(height: 57)
                    Spacer()
                        .frame(height: 19)
                    TellaButtonView<AnyView>(title: LocalizableSettings.UwaziAuthenticationVerify.localized,
                                             nextButtonAction: .action,
                                             isValid: $validCredentials) {
                        UIApplication.shared.endEditing()
                        showLanguageView = true
                    }
                    Spacer()
                }
                .padding(.leading, 23)
                .padding(.trailing,23)
                nextViewLink
                BottomLockView<AnyView>(isValid: $validPassword,
                                        nextButtonAction: .action,
                                        shouldHideNext: true)
            }
        }
        .navigationBarHidden(true)
    }
    @ViewBuilder
    private var nextViewLink: some View {
        UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(SettingsViewModel(appModel: MainAppModel()))
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
            //.addNavigationLink(isActive: $showLanguageView)
    }
}

struct UwaziTwoStepVerification_Previews: PreviewProvider {
    static var previews: some View {
        UwaziTwoStepVerification()
    }
}
