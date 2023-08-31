//
//  UwaziAddServerURLView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziAddServerURLView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var nextButtonAction: NextButtonAction = .action
    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var uwaziServerViewModel : UwaziServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    init(appModel:MainAppModel, server: Server? = nil) {
        _uwaziServerViewModel = StateObject(wrappedValue: UwaziServerViewModel(mainAppModel: appModel, currentServer: server))
    }
    var body: some View {

        ContainerView {

            ZStack {

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    Image("settings.server")


                    Spacer()
                        .frame(height: 24)

                    Text(LocalizableSettings.UwaziServerURL.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 18))
                        .foregroundColor(.white)

                    Spacer()
                        .frame(height: 40)
                    TextfieldView(fieldContent: $uwaziServerViewModel.serverURL,
                                  isValid: $uwaziServerViewModel.validURL,
                                  shouldShowError: $uwaziServerViewModel.shouldShowURLError,
                                  errorMessage: uwaziServerViewModel.urlErrorMessage,
                                  fieldType: .url)
                    Spacer()

                    BottomLockView<AnyView>(isValid: $uwaziServerViewModel.validURL,
                                            nextButtonAction: .action,
                                            nextAction: {
                        self.uwaziServerViewModel.checkURL()
                    },
                                            backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                if uwaziServerViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            #if DEBUG
                        uwaziServerViewModel.serverURL = "https://horizontal.uwazi.io"
            #endif
            guard (uwaziServerViewModel.currentServer != nil) else { return }
            uwaziServerViewModel.validURL = true
        }
        .onReceive(uwaziServerViewModel.$isPublicInstance) { isPublicInstance in
            guard let isPublicInstance = isPublicInstance else { return }
            handleNavigation(isPublicInstance: isPublicInstance)
        }
    }
    func handleNavigation(isPublicInstance: Bool) {
        if isPublicInstance {
            let serverAccess = UwaziServerAccessSelectionView()
                .environmentObject(uwaziServerViewModel)
                .environmentObject(serversViewModel)
            navigateTo(destination: serverAccess)
        } else {
            let loginView = UwaziLoginView()
                .environmentObject(serversViewModel)
                .environmentObject(uwaziServerViewModel)
            navigateTo(destination: loginView)
        }
    }
}

struct UwaziAddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziAddServerURLView(appModel: MainAppModel.stub())
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}
