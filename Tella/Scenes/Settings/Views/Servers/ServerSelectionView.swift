//
//  ServerSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/12/23.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine

struct ServerSelectionView: View {
    @ObservedObject var serversViewModel : ServersViewModel
    @ObservedObject var gDriveServerVM: GDriveServerViewModel
    @ObservedObject var dropboxServerVM: DropboxServerViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(serversViewModel : ServersViewModel) {
        self.serversViewModel = serversViewModel
        _gDriveServerVM = ObservedObject(wrappedValue:GDriveServerViewModel(repository: serversViewModel.gDriveRepository,
                                                                            mainAppModel: serversViewModel.mainAppModel,
                                                                            serversSourceView: serversViewModel.serversSourceView))
        _dropboxServerVM = ObservedObject(wrappedValue: DropboxServerViewModel(dropboxRepository: serversViewModel.dropboxRepository, mainAppModel: serversViewModel.mainAppModel))
    }
    
    var body: some View {
        Group {
            ContainerViewWithHeader {
                if serversViewModel.serversSourceView == .settings {
                    navigationBarView
                }
            } content: {
                contentView
            }
        }
        .onReceive(gDriveServerVM.$signInState){ signInState in
            if case .error(let message) = signInState {
                Toast.displayToast(message: message)
            }
        }
        .onReceive(Publishers.CombineLatest(dropboxServerVM.$signInState, dropboxServerVM.$addServerState)) { signInState, addServerState in
            handleDropboxStateChange(signInState: signInState, addServerState: addServerState)
        }
        .onOpenURL { url in
            dropboxServerVM.handleURLRedirect(url: url)
        }
        .onReceive(serversViewModel.$shouldHideView) { shouldHideView in
            if shouldHideView {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settServersAppBar.localized)
    }
    
    var contentView: some View {
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
    
    fileprivate func bottomView() -> NavigationBottomView<AnyView> {
        return NavigationBottomView<AnyView>(shouldActivateNext: $serversViewModel.shouldEnableNextButton,
                                       nextButtonAction: .action,
                                       shouldHideBack: serversViewModel.serversSourceView == .settings,
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
        navigateTo(destination: NextcloudAddServerURLView(nextcloudVM: NextcloudServerViewModel(mainAppModel: serversViewModel.mainAppModel, serversSourceView: serversViewModel.serversSourceView)))
    }
    
    fileprivate func navigateToTellaWebFlow() {
        navigateTo(destination: TellaWebAddServerURLView(mainAppModel: serversViewModel.mainAppModel, serversSourceView: serversViewModel.serversSourceView))
    }
    
    fileprivate func navigateToUwaziFlow() {
        navigateTo(destination: UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: serversViewModel.mainAppModel, serversSourceView: serversViewModel.serversSourceView)))
    }
    
    fileprivate func navigateToGDriveFlow() {
        gDriveServerVM.handleSignIn {
            DispatchQueue.main.async() {
                navigateTo(
                    destination: CreateDriveFolderView(gDriveServerViewModel: gDriveServerVM)
                )
            }
        }
    }
    
    fileprivate func navigateToDropbox() {
        dropboxServerVM.handleSignIn()
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
    
    private func handleDropboxStateChange(signInState: ViewModelState<Bool>, addServerState: ViewModelState<Bool>) {
        switch (signInState, addServerState) {
        case (.loaded(true), .loaded(true)):
            navigateTo(destination: SuccessLoginView(navigateToAction: {
                self.popToRoot()
            }, type: .dropbox))
        case (_, .error(let message)):
            Toast.displayToast(message: message)
        case (.error(let message), _):
            Toast.displayToast(message: message)
        default:
            break
        }
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
                
                learnMoreView
                Text(LocalizableSettings.settServerSelectionPart2Message.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
        }
        var learnMoreView: some View {
            Button {
                TellaUrls.connectionLearnMore.url()?.open()
            } label: {
                Text(LocalizableSettings.settServerSelectionPart1Message.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Styles.Colors.yellow)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView(serversViewModel: ServersViewModel.stub())
    }
}
