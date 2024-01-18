//
//  UwaziServerAccessSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziServerAccessSelectionView: View {
    enum UwaziAccessServerType {
        case publicServer
        case privateServer
        case none
    }

    @State var isButtonValid = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var accessServerType: UwaziAccessServerType = .none
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var uwaziServerViewModel : UwaziServerViewModel

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
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .navigationBarBackButtonHidden(true)

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
    fileprivate func buttonView() -> some View {
        return VStack(spacing: 12) {
            TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                     nextButtonAction: .action,
                                     isOverlay: accessServerType == .privateServer,
                                     isValid: .constant(true),action: {
                accessServerType = .privateServer
            })
            TellaButtonView<AnyView>(title: LocalizableSettings.UwaziPublicInstance.localized,
                                     nextButtonAction: .action,
                                     isOverlay: accessServerType == .publicServer,
                                     isValid: .constant(true),action: {
                accessServerType = .publicServer
            })
        }
    }

    fileprivate func handleNavigation() {
        switch accessServerType {
        case .publicServer:
            navigateToLanguageView()
        case .privateServer:
            navigateToLoginView()
        case .none:
            break
        }
    }
    fileprivate func navigateToLoginView() {
        let loginView = UwaziLoginView()
            .environmentObject(serversViewModel)
            .environmentObject(uwaziServerViewModel)
        navigateTo(destination: loginView)
    }

    fileprivate func navigateToLanguageView() {
        let languageSelection = UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(serversViewModel)
            .environmentObject(uwaziServerViewModel)
        navigateTo(destination: languageSelection)
    }

}

struct UwaziServerAccessSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziServerAccessSelectionView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}




