//
//  UwaziServerAccessSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziServerAccessSelectionView: View {
    @State var isButtonValid = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // TODO: Ask if there is any good way to do it
    @State var isLoginSelected: Bool = false
    @State var isPublicInstance: Bool = false

    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var serverViewModel : UwaziServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel

    var body: some View {
        ContainerView {
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    HeaderView()
                    Spacer().frame(height:24)
                    buttonView()
                }
                Spacer()
                BottomLockView<AnyView>(isValid: $isButtonValid,
                                        nextButtonAction: .action,
                                        nextAction: {
                    handleNavigation()
                },
                backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .navigationBarBackButtonHidden(true)

    }
    fileprivate func buttonView() -> VStack<TupleView<(TellaButtonView<AnyView>, TellaButtonView<AnyView>)>> {
        return VStack(spacing: 12) {
            TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                     nextButtonAction: .action,
                                     isOverlay: self.isLoginSelected,
                                     isValid: .constant(true),action: {
                self.isLoginSelected = true
                self.isPublicInstance = false
            })
            TellaButtonView<AnyView>(title: LocalizableSettings.UwaziPublicInstance.localized,
                                     nextButtonAction: .action,
                                     isOverlay: self.isPublicInstance,
                                     isValid: .constant(true),action: {
                self.isLoginSelected = false
                self.isPublicInstance = true
            })
        }
    }

    fileprivate func handleNavigation() {
        if isLoginSelected {
            navigateToLoginView()
        } else if isPublicInstance {
            navigateToLanguageView()
        } else {}
    }
    fileprivate func navigateToLoginView() {
        let loginView = UwaziLoginView()
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
        navigateTo(destination: loginView)
    }

    fileprivate func navigateToLanguageView() {
        let languageSelection = UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
        navigateTo(destination: languageSelection)
    }
    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image("settings.server")
                Text(LocalizableSettings.UwaziAccessServerTitle.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct UwaziServerAccessSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziServerAccessSelectionView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}
