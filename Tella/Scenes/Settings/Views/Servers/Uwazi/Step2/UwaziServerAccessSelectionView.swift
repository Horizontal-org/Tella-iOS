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
    @State var isLoginSelected: Bool = false
    @State var isPublicInstance: Bool = false
    @State var showLogin: Bool = false
    @State var showAccess: Bool = false

    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var serverViewModel : ServerViewModel

    init(appModel:MainAppModel, server: Server? = nil) {
        _serverViewModel = StateObject(wrappedValue: ServerViewModel(mainAppModel: appModel, currentServer: server))
    }
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
                        showLogin = true
                    } else if isPublicInstance {
                        showAccess = true
                    } else {

                    }
                },
                                        backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
            loginLink
            publicLink
        }
        .navigationBarBackButtonHidden(true)

    }
    private var loginLink: some View {
        UwaziLoginView()
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
            //.addNavigationLink(isActive: $showLogin)
    }
    private var publicLink: some View {
        UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(SettingsViewModel(appModel: MainAppModel()))
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
            //.addNavigationLink(isActive: $showAccess)
    }
}

struct UwaziServerAccessSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziServerAccessSelectionView(appModel: MainAppModel())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel(), currentServer: nil))
    }
}
