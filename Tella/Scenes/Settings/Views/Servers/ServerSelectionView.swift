//
//  ServerSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/12/23.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ServerSelectionView: View {
    @ObservedObject var serversViewModel : ServersViewModel
    @ObservedObject var gDriveServerVM: GDriveServerViewModel
    @StateObject private var dropboxServerVM: DropboxServerViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(serversViewModel : ServersViewModel) {
        self.serversViewModel = serversViewModel
        _gDriveServerVM = ObservedObject(wrappedValue:GDriveServerViewModel(repository: serversViewModel.gDriveRepository,
                                                                            mainAppModel: serversViewModel.mainAppModel,
                                                                            serversSourceView: serversViewModel.serversSourceView))
        _dropboxServerVM = StateObject(wrappedValue: DropboxServerViewModel(dropboxRepository: serversViewModel.dropboxRepository, mainAppModel: serversViewModel.mainAppModel))
    }
    
    var body: some View {
        Group {
            if dropboxServerVM.shouldShowSuccessScreen {
                SuccessLoginView(navigateToAction: {
                    navigateTo(destination: dropboxReportsView)
                }, type: .dropbox)
            } else {
                ContainerViewWithHeader {
                    if serversViewModel.serversSourceView == .settings {
                        navigationBarView
                    }
                } content: {
                    contentView
                }
            }
        }
        .onReceive(gDriveServerVM.$signInState){ signInState in
            if case .error(let message) = signInState {
                Toast.displayToast(message: message)
            }
        }
        .onReceive(dropboxServerVM.$signInState) { state in
            if case .error(let message) = state {
                Toast.displayToast(message: message)
            }
        }
        .onReceive(dropboxServerVM.$addServerState) { state in
            if case .error(let message) = state {
                Toast.displayToast(message: message)
            }
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
            Spacer()
            bottomView()
        }.scrollOnOverflow()
    }
    
    fileprivate func buttonViews() -> some View {
        return Group {
            ForEach(serverConnections, id: \.type) { connection in
                TellaButtonView(
                    title: connection.title,
                    nextButtonAction: .action,
                    isOverlay: serversViewModel.selectedServerType == connection.type,
                    isValid: .constant(true),
                    action: {
                        if serversViewModel.isConnectionUnavailable(connection.type) {
                            showUnavailableConnectionSheet(connection.type)
                        } else {
                            serversViewModel.selectedServerType = connection.type
                            serversViewModel.shouldEnableNextButton = true
                        }
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
    
    private var dropboxReportsView: DropboxReportMainView {
        DropboxReportMainView(reportsMainViewModel: DropboxViewModel(mainAppModel: serversViewModel.mainAppModel,
                                                                     dropboxRepository: serversViewModel.dropboxRepository))
    }
    
    private func showUnavailableConnectionSheet(_ type: ServerConnectionType) {
        let message = String(format: LocalizableSettings.settServerUnavailableConnectionsDesc.localized,
                             type.connectionName).addTwolines
        + LocalizableSettings.settServerUnavailableConnectionsDesc2.localized
        let content = ConfirmBottomSheet(titleText: LocalizableSettings.settServerUnavailableConnectionsTitle.localized,
                                         msgText: message,
                                         actionText: LocalizableLock.loseFileWarningUnderstand.localized,
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            self.dismiss()
        })
        showBottomSheetView(content: content)
    }
    
    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image("settings.server")
                CustomText(LocalizableSettings.settServerSelectionTitle.localized,
                           style: .heading1Style,
                           alignment: .center)
                
                learnMoreView
                CustomText(LocalizableSettings.settServerSelectionPart2Message.localized,
                           style: .body1Style,
                           alignment: .center)
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
        }
        var learnMoreView: some View {
            Button {
                TellaUrls.connectionLearnMore.url()?.open()
            } label: {
                CustomText(LocalizableSettings.settServerSelectionPart1Message.localized,
                           style: .body1Style,
                           alignment: .center,
                           color: Styles.Colors.yellow)
            }
        }
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView(serversViewModel: ServersViewModel.stub())
    }
}
