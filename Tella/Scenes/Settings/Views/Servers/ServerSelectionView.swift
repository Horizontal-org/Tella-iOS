//
//  ServerSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine
struct ServerSelectionView: View {
    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var serverViewModel : TellaWebServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @State var selectedServerType: ServerConnectionType? = nil
    @ObservedObject var gDriveVM: GDriveAuthViewModel
    @ObservedObject var gDriveServerVM: GDriveServerViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gDriveDIContainer: GDriveDIContainer

    
    init(appModel:MainAppModel, server: TellaServer? = nil, gDriveDIContainer: GDriveDIContainer) {
        self.gDriveDIContainer = gDriveDIContainer
        _serverViewModel = StateObject(wrappedValue: TellaWebServerViewModel(mainAppModel: appModel, currentServer: server))
        _gDriveVM = ObservedObject(wrappedValue: GDriveAuthViewModel(repository: gDriveDIContainer.gDriveRepository))
        _gDriveServerVM = ObservedObject(wrappedValue:GDriveServerViewModel(repository: gDriveDIContainer.gDriveRepository, mainAppModel: appModel))
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
        }.onReceive(gDriveVM.$signInState){ signInState in
            if case .error(let message) = signInState {
                Toast.displayToast(message: message)
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
            case .nextcloud:
                navigateToNextCloud()
            default:
                break
            }
        })
    }

    fileprivate func navigateToNextCloud() {
        navigateTo(destination: NextcloudAddServerURLView(nextcloudVM: NextcloudServerViewModel(mainAppModel: mainAppModel)))
    }
    
    fileprivate func navigateToTellaWebFlow() {
        navigateTo(destination: TellaWebAddServerURLView(appModel: mainAppModel))
    }

    fileprivate func navigateToUwaziFlow() {
        navigateTo(destination: UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: mainAppModel))
            .environmentObject(serverViewModel)
            .environmentObject(serversViewModel))
    }
    
    fileprivate func navigateToGDriveFlow() {
        gDriveVM.handleSignIn {
            navigateTo(
                destination: SelectDriveConnection(gDriveServerViewModel: gDriveServerVM),
                title: LocalizableSettings.settServerGDrive.localized
            )
        }
    }

    fileprivate func unavailableConnectionsView() -> some View {
        VStack(spacing: 20) {
            SectionTitle(text: LocalizableSettings.settServerUnavailableConnectionsTitle.localized)
            SectionMessage(text: LocalizableSettings.settServerUnavailableConnectionsDesc.localized)
            ForEach(serversViewModel.unavailableServers, id: \.serverType) { server in
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
        ServerSelectionView(appModel: MainAppModel.stub(), gDriveDIContainer: GDriveDIContainer())
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
