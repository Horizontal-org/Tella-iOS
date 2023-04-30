//
//  UwaziTwoStepVerification.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziTwoStepVerification: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var serverViewModel : UwaziServerViewModel
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
                    TextfieldView(fieldContent: $serverViewModel.code,
                                  isValid: $serverViewModel.validCode,
                                  shouldShowError: $serverViewModel.shouldShowAuthenticationError,
                                  errorMessage: serverViewModel.codeErrorMessage,
                                  fieldType: .code,
                                  placeholder: LocalizableSettings.UwaziAuthenticationPlaceholder.localized)
                                .keyboardType(.numberPad)
                    .frame(height: 57)
                    Spacer()
                        .frame(height: 19)
                    TellaButtonView<AnyView>(title: LocalizableSettings.UwaziAuthenticationVerify.localized,
                                             nextButtonAction: .action,
                                             isValid: $serverViewModel.validAuthenticationCode) {
                        UIApplication.shared.endEditing()
                        let languageView = UwaziLanguageSelectionView(isPresented: .constant(true))
                            .environmentObject(SettingsViewModel(appModel: MainAppModel()))
                            .environmentObject(serversViewModel)
                            .environmentObject(serverViewModel)
                        navigateTo(destination: languageView)
                    }
                    Spacer()
                }
                .padding(.leading, 23)
                .padding(.trailing,23)
                BottomLockView<AnyView>(isValid: .constant(true),
                                        nextButtonAction: .action,
                                        shouldHideNext: true)
            }
        }
        .navigationBarHidden(true)
    }
}

struct UwaziTwoStepVerification_Previews: PreviewProvider {
    static var previews: some View {
        UwaziTwoStepVerification()
    }
}
