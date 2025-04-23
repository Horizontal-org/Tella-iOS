//
//  UwaziTwoStepVerification.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziTwoStepVerification: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var uwaziServerViewModel : UwaziServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel

    var body: some View {
        ContainerView {
            ZStack {
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
                        TextfieldView(fieldContent: $uwaziServerViewModel.code,
                                      isValid: $uwaziServerViewModel.validCode,
                                      shouldShowError: $uwaziServerViewModel.shouldShowAuthenticationError,
                                      errorMessage: uwaziServerViewModel.codeErrorMessage,
                                      fieldType: .code,
                                      placeholder: LocalizableSettings.UwaziAuthenticationPlaceholder.localized)
                        .frame(height: 57)
                        Spacer()
                            .frame(height: 19)
                        TellaButtonView<AnyView>(title: LocalizableSettings.UwaziAuthenticationVerify.localized,
                                                 nextButtonAction: .action,
                                                 isValid: $uwaziServerViewModel.validAuthenticationCode) {
                            UIApplication.shared.endEditing()
                            uwaziServerViewModel.twoFactorAuthentication()
                        }
                        Spacer()
                    }
                    .padding(.leading, 23)
                    .padding(.trailing,23)
                    NavigationBottomView<AnyView>(shouldActivateNext: .constant(true),
                                            nextButtonAction: .action,
                                            shouldHideNext: true)
                }
                if uwaziServerViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(uwaziServerViewModel.$showLanguageSelectionView) { value in
            if value {
                let languageView = UwaziLanguageSelectionView(isPresented: .constant(true))
                    //.environmentObject(SettingsViewModel(appModel: MainAppModel()))
                    .environmentObject(serversViewModel)
                    .environmentObject(uwaziServerViewModel)
                navigateTo(destination: languageView)
            }
        }
    }
}

struct UwaziTwoStepVerification_Previews: PreviewProvider {
    static var previews: some View {
        UwaziTwoStepVerification()
    }
}
