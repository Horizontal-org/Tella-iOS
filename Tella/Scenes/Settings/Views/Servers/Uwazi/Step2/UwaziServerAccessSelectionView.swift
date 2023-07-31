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
                Image("settings.server")
                VStack(spacing: 12) {
                    Text(LocalizableSettings.UwaziAccessServerTitle.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height:24)
                    TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                             nextButtonAction: .action,
                                             isValid: .constant(true),action: {
                        self.isLoginSelected = true
                        self.isPublicInstance = false
                    })
                    .overlay( self.isLoginSelected ?
                              RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 4) : nil
                    )
                    TellaButtonView<AnyView>(title: LocalizableSettings.UwaziPublicInstance.localized,
                                             nextButtonAction: .action,
                                             isValid: .constant(true),action: {
                        self.isLoginSelected = false
                        self.isPublicInstance = true
                    })
                    .overlay( self.isPublicInstance ?
                              RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 4) : nil
                    )
                }.padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                Spacer()
                BottomLockView<AnyView>(isValid: $isButtonValid,
                                        nextButtonAction: .action,
                                        nextAction: {
                    if isLoginSelected {
                        let loginView = UwaziLoginView()
                            .environmentObject(serversViewModel)
                            .environmentObject(serverViewModel)
                        navigateTo(destination: loginView)
                    } else if isPublicInstance {
                        let languageSelection = UwaziLanguageSelectionView(isPresented: .constant(true))
                            //.environmentObject(SettingsViewModel(appModel: mainAppModel))
                            .environmentObject(serversViewModel)
                            .environmentObject(serverViewModel)
                        navigateTo(destination: languageSelection)
                    } else {

                    }
                },
                backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .onAppear {
            if let server = serverViewModel.currentServer {
                if server.username == "" {
                    self.isPublicInstance = true
                } else {
                    self.isLoginSelected = true
                }
            }

        }
        .navigationBarBackButtonHidden(true)

    }
}

struct UwaziServerAccessSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziServerAccessSelectionView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}

