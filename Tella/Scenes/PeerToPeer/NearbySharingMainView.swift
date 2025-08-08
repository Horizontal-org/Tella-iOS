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
        NavigationHeaderView(title: LocalizableNearbySharing.nearbySharingAppBar.localized)
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
            imageIconName: "p2p.share",
            subtitleTextAlignment: .leading)
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
            TellaUrls.p2pLearnMore.url()?.open()
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
            guard let participant  else { return }
            let wifiConnetionViewModel = WifiConnetionViewModel(participant: participant, mainAppModel: mainAppModel)
            navigateTo(destination: WifiConnetionView(viewModel:wifiConnetionViewModel,
                                                      mainAppModel: mainAppModel))
        })
    }
}

#Preview {
    NearbySharingMainView(mainAppModel: MainAppModel.stub())
}
