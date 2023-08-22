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
    @StateObject var serverViewModel : UwaziServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel

    init(appModel:MainAppModel, server: Server? = nil) {
        _serverViewModel = StateObject(wrappedValue: UwaziServerViewModel(mainAppModel: appModel, currentServer: server))
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

                    TextfieldView(fieldContent: $serverViewModel.serverURL,
                                  isValid: $serverViewModel.validURL,
                                  shouldShowError: $serverViewModel.shouldShowURLError,
                                  errorMessage: serverViewModel.urlErrorMessage,
                                  fieldType: .url)
                    Spacer()

                    BottomLockView<AnyView>(isValid: $serverViewModel.validURL,
                                            nextButtonAction: .action,
                                            nextAction: {
                        self.serverViewModel.checkURL()

                    },
                                            backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
#if DEBUG
            serverViewModel.serverURL = "https://horizontal.uwazi.io"
#endif
            guard (serverViewModel.currentServer != nil) else { return }
            serverViewModel.validURL = true

        }
        .onReceive(serverViewModel.$isPublicInstance) { value in
            if value {
                let serverAccess = UwaziServerAccessSelectionView().environmentObject(serverViewModel).environmentObject(serversViewModel)
                navigateTo(destination: serverAccess)
            }
        }
        .onReceive(serverViewModel.$isPrivateInstance) { value in
            if value {
                let loginView = UwaziLoginView()
                    .environmentObject(serversViewModel)
                    .environmentObject(serverViewModel)
                navigateTo(destination: loginView)
            }
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
