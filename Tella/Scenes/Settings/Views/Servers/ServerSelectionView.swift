//
//  ServerSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ServerSelectionView: View {
    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var serverViewModel : ServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @State var selectedServerType: ServerConnectionType = .unknown
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(appModel:MainAppModel, server: Server? = nil) {
        _serverViewModel = StateObject(wrappedValue: ServerViewModel(mainAppModel: appModel, currentServer: server))
    }
    var body: some View {
        ContainerView {

            VStack(spacing: 20) {
                Spacer()
                HeaderView()
                buttonViews()
                Spacer()
                bottomView()
            }
            .toolbar {
                LeadingTitleToolbar(title: LocalizableSettings.settConnections.localized)
            }
        }
    }
    fileprivate func buttonViews() -> Group<TupleView<(some View, some View)>> {
        return Group {
            TellaButtonView<AnyView>(title: LocalizableSettings.settServerTellaWeb.localized,
                                     nextButtonAction: .action,
                                     isOverlay: selectedServerType == .tella,
                                     isValid: .constant(true),action: {
                selectedServerType = .tella
            })
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            TellaButtonView<AnyView>(title: LocalizableSettings.settServerUwazi.localized,
                                     nextButtonAction: .action,
                                     isOverlay: selectedServerType == .uwazi,
                                     isValid: .constant(true), action: {
                selectedServerType = .uwazi
            }).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
    }

    fileprivate func bottomView() -> BottomLockView<AnyView> {
        return BottomLockView<AnyView>(isValid: .constant(true),
                                       nextButtonAction: .action,
                                       shouldHideNext: false,
                                       shouldHideBack: true,
                                       nextAction: {
            switch selectedServerType {
            case .tella:
                navigateToTellaWebFlow()
            case .uwazi:
                navigateToUwaziFlow()
            default:
                break
            }
        })
    }

    fileprivate func navigateToTellaWebFlow() {
        navigateTo(destination: AddServerURLView(appModel: mainAppModel))
    }

    fileprivate func navigateToUwaziFlow() {
        navigateTo(destination: UwaziAddServerURLView(appModel: mainAppModel)
            .environmentObject(serverViewModel)
            .environmentObject(serversViewModel))
    }


    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image("settings.server")
                Text(LocalizableSettings.settServerSelectionTitle.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(LocalizableSettings.settServerSelectionMessage.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView(appModel: MainAppModel.stub())
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
