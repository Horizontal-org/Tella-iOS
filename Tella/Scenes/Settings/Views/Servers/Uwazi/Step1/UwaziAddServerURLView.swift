//
//  UwaziAddServerURLView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziAddServerURLView: View {
    //    @EnvironmentObject var serversViewModel : ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    //    var action : (() -> Void)?
    var nextButtonAction: NextButtonAction = .action


    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var serverViewModel : ServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @State var showNextLoginView : Bool = false

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

                    TextfieldView(fieldContent: $serverViewModel.projectURL,
                                  isValid: $serverViewModel.validURL,
                                  shouldShowError: $serverViewModel.shouldShowURLError,
                                  errorMessage: serverViewModel.urlErrorMessage,
                                  fieldType: .url)
                    Spacer()

                    BottomLockView<AnyView>(isValid: $serverViewModel.validURL,
                                            nextButtonAction: .action,
                                            nextAction: {
                        //                        serverViewModel.checkURL()
                        self.showNextLoginView = true
                    },
                                            backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })

                    nextViewLink

                } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {

#if DEBUG
            serverViewModel.projectURL = "https://api.beta.web.tella-app.org/p/dhekra"
#endif
        }
    }

    private var nextViewLink: some View {
        UwaziServerAccessSelectionView(appModel: mainAppModel)
            .environmentObject(serverViewModel)
            .environmentObject(serversViewModel)
            //.addNavigationLink(isActive: $showNextLoginView, destination: <#_#>)
    }
}

struct UwaziAddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziAddServerURLView()
            .environmentObject(MainAppModel())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel(), currentServer: nil))
    }
}
