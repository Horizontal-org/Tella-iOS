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
    @ObservedObject var gDriveVM: GDriveAuthViewModel
    @ObservedObject var gDriveServerVM: GDriveServerViewModel
    @ObservedObject var dropboxVM: DropboxAuthViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gDriveRepository: GDriveRepositoryProtocol
    let dropboxRepository: DropboxRepositoryProtocol
    
    init(appModel:MainAppModel, server: TellaServer? = nil, gDriveRepository: GDriveRepositoryProtocol, dropboxRepository: DropboxRepositoryProtocol) {
        self.gDriveRepository = gDriveRepository
        self.dropboxRepository = dropboxRepository
        _gDriveVM = ObservedObject(wrappedValue: GDriveAuthViewModel(repository: gDriveRepository))
        _gDriveServerVM = ObservedObject(wrappedValue:GDriveServerViewModel(repository: gDriveRepository, mainAppModel: appModel))
        _dropboxVM = ObservedObject(wrappedValue: DropboxAuthViewModel(dropboxRepository: dropboxRepository))
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
            }.scrollOnOverflow()
            .toolbar {
                LeadingTitleToolbar(title: LocalizableSettings.settServersAppBar.localized)
            }
        }.onReceive(gDriveVM.$signInState){ signInState in
            if case .error(let message) = signInState {
                Toast.displayToast(message: message)
            }
        }.onOpenURL { url in
            dropboxVM.handleURLRedirect(url: url)
        }
        
    }
    
    fileprivate func buttonViews() -> some View {
        return Group {
            ForEach(serversViewModel.filterServerConnections(), id: \.type) { connection in
                TellaButtonView<AnyView>(
                    title: connection.title,
                    nextButtonAction: .action,
                    isOverlay: serversViewModel.selectedServerType == connection.type,
                    isValid: .constant(true),
                    action: {
                        serversViewModel.selectedServerType = connection.type
                        serversViewModel.shouldEnableNextButton = true
                     }
                )
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
        }
    }

    fileprivate func bottomView() -> BottomLockView<AnyView> {
        return BottomLockView<AnyView>(isValid: $serversViewModel.shouldEnableNextButton,
                                       nextButtonAction: .action,
                                       shouldHideBack: true,
                                       nextAction: {
            switch serversViewModel.selectedServerType {
            case .tella:
                navigateToTellaWebFlow()
            case .uwazi:
                navigateToUwaziFlow()
            case .gDrive:
                navigateToGDriveFlow()
            case .nextcloud:
                navigateToNextCloud()
            case .dropbox:
                navigateToDropbox()
            default:
                break
            }
            
            resetView()
        })
    }
    
    fileprivate func resetView() {
        serversViewModel.selectedServerType = nil
        serversViewModel.shouldEnableNextButton = false
    }

    fileprivate func navigateToNextCloud() {
        navigateTo(destination: NextcloudAddServerURLView(nextcloudVM: NextcloudServerViewModel(mainAppModel: serversViewModel.mainAppModel)))
    }
    
    fileprivate func navigateToTellaWebFlow() {
        navigateTo(destination: TellaWebAddServerURLView(appModel: serversViewModel.mainAppModel))
    }

    fileprivate func navigateToUwaziFlow() {
        navigateTo(destination: UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: serversViewModel.mainAppModel))
            .environmentObject(serversViewModel))
    }
    
    fileprivate func navigateToGDriveFlow() {
        gDriveVM.handleSignIn {
            navigateTo(
                destination: SelectDriveConnectionView(gDriveServerViewModel: gDriveServerVM),
                title: LocalizableSettings.settServerGDrive.localized
            )
        }
    }
    
    fileprivate func navigateToDropbox() {
        dropboxVM.handleSignIn() {
            navigateTo(destination: SuccessLoginView(navigateToAction: {}, type: .dropbox))
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
                    .fixedSize(horizontal: false, vertical: true)
                Text(LocalizableSettings.settServerSelectionMessage.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView(appModel: MainAppModel.stub(), gDriveRepository: GDriveRepository(), dropboxRepository: DropboxRepository())
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
