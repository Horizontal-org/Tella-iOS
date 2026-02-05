//
//  NearbySharingMainView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct NearbySharingMainView: View {
    
    @StateObject var mainAppModel: MainAppModel
    @State var participant: NearbySharingParticipant?
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.nearbySharingMainAppBar.localized,
                             rightButtonType: .help) {
            navigateTo(destination: NearbySharingHelpView())
        }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            headerView
            nearbySharingParticipantButtons
            learnMoreView
            Spacer()
            bottomView
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizableNearbySharing.nearbySharingSubhead.localized,
            subtitle: LocalizableNearbySharing.nearbySharingExpl.localized,
            imageIconName: .nearbySharingMain)
    }
    
    var nearbySharingParticipantButtons: some View {
        VStack(spacing: 12) {
            
            TellaButtonView(title: LocalizableNearbySharing.sendFiles.localized.uppercased(),
                            nextButtonAction: .action,
                            isOverlay: participant == .sender,
                            isValid: .constant(true),
                            action: { participant = .sender }
            ).frame(height: 54)
            TellaButtonView(title: LocalizableNearbySharing.receiveFiles.localized.uppercased(),
                            nextButtonAction: .action,
                            isOverlay: participant == .recipient,
                            isValid: .constant(true),
                            action: {participant = .recipient}
            ).frame(height: 54)
        }
    }
    
    var learnMoreView: some View {
        Button {
            TellaUrls.nearbySharingLearnMore.url()?.open()
        } label: {
            CustomText(LocalizableNearbySharing.learnMore.localized,
                       style: .buttonDetailRegularStyle,
                       alignment: .center,
                       color: Styles.Colors.yellow)
        }
    }
    
    var bottomView: some View {
        NavigationBottomView<AnyView>(shouldActivateNext: Binding(get: { participant != nil },
                                                                  set: { _ in }),
                                      nextButtonAction: .action,
                                      shouldHideBack: true,
                                      nextAction: {
            if mainAppModel.settings.showSameWiFiNetworkAlert {
                let view = SameNetworkBottomSheet(mainAppModel: mainAppModel) {
                    showConnectToDeviceView()
                }
                self.showBottomSheetView(content: view)
                
            } else {
                showConnectToDeviceView()
            }
        })
    }
    
    func showConnectToDeviceView() {
        switch participant {
        case .sender:
            let senderConnectToDeviceViewModel = SenderConnectToDeviceViewModel(nearbySharingRepository:NearbySharingRepository(),
                                                                                mainAppModel: mainAppModel)
            navigateTo(destination: SenderConnectToDeviceView(viewModel:senderConnectToDeviceViewModel))
        case .recipient:
            let recipientConnectToDeviceViewModel = RecipientConnectToDeviceViewModel(certificateGenerator: CertificateGenerator(),
                                                                                      mainAppModel: mainAppModel)
            navigateTo(destination: RecipientConnectToDeviceView(viewModel: recipientConnectToDeviceViewModel))
        case .none:
            break
        }
    }
}

#Preview {
    NearbySharingMainView(mainAppModel: MainAppModel.stub())
}
