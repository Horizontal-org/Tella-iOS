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
    @State var selectedServerType: ServerConnectionType? = nil
    @ObservedObject var gDriveVM = GDriveAuthViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(appModel:MainAppModel, server: TellaServer? = nil) {
        _serverViewModel = StateObject(wrappedValue: ServerViewModel(mainAppModel: appModel, currentServer: server))
    }
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                Spacer()
                HeaderView()
                buttonViews()
                if(!serversViewModel.unavailableServers.isEmpty) {
                    unavailableConnectionsView()
                }
                Spacer()
                bottomView()
            }
            .toolbar {
                LeadingTitleToolbar(title: LocalizableSettings.settServersAppBar.localized)
            }
        }
    }
    
    fileprivate func buttonViews() -> some View {
        return Group {
            ForEach(serversViewModel.filterServerConnections(), id: \.type) { connection in
                TellaButtonView<AnyView>(
                    title: connection.title,
                    nextButtonAction: .action,
                    isOverlay: selectedServerType == connection.type,
                    isValid: .constant(true),
                    action: {
                        selectedServerType = connection.type
                    }
                )
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
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
            case .gDrive:
                navigateToGDriveFlow()
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
    
    fileprivate func navigateToGDriveFlow() {
        gDriveVM.handleSignIn { 
            navigateTo(
                destination: SelectDriveConnection(gDriveServerViewModel: GDriveServerViewModel(mainAppModel: mainAppModel)),
                title: "Select Google drive"
            )
        }
    }

    fileprivate func unavailableConnectionsView() -> some View {
        VStack(spacing: 20) {
            SectionTitle(text: "Unavailable connections")
            SectionMessage(text: "For the following categories, only one connection can be enabled at a time. To add a new connection, please delete the current one by going to Connections Settings.")
            ForEach(serversViewModel.unavailableServers, id: \.id) { server in
                TellaButtonView<AnyView>(
                    title: server.serverType?.serverTitle ?? "",
                    nextButtonAction: .action,
                    isValid: .constant(false)
                )
            }
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
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
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
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
