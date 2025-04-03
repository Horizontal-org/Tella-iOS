//
//  PeerToPeerMainView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct PeerToPeerMainView: View {
    
    @StateObject var mainAppModel: MainAppModel
    @State var participant: PeerToPeerParticipant?
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.peerToPeerAppBar.localized)
    }
    
    var contentView: some View {
        VStack {
            Spacer()
                .frame(height: 35)
            
            headerView
            
            Spacer()
                .frame(height: 24)
            
            peerToPeerParticipantButtons
            
            learnMoreView.padding()
            
            Spacer()
            bottomView
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizablePeerToPeer.nearbySharingSubhead.localized,
            subtitle: LocalizablePeerToPeer.nearbySharingExpl.localized,
            imageIconName: "p2p.share",
            subtitleTextAlignment: .leading)
    }
    
    var peerToPeerParticipantButtons: some View {
        VStack(spacing: 12) {
            
            TellaButtonView<AnyView>(title: LocalizablePeerToPeer.sendFiles.localized.uppercased(),
                                     nextButtonAction: .action,
                                     isOverlay: participant == .sender,
                                     isValid: .constant(true),
                                     action: { participant = .sender }
            ).frame(height: 54)
            TellaButtonView<AnyView>(title: LocalizablePeerToPeer.receiveFiles.localized.uppercased(),
                                     nextButtonAction: .action,
                                     isOverlay: participant == .recipient,
                                     isValid: .constant(true),
                                     action: {participant = .recipient}
            ).frame(height: 54)
        }
    }
    
    var learnMoreView: some View {
        Button {
            TellaUrls.connectionLearnMore.url()?.open()
        } label: {
            Text(LocalizablePeerToPeer.learnMore.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Styles.Colors.yellow)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: Binding(get: { participant != nil },
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
    PeerToPeerMainView(mainAppModel: MainAppModel.stub())
}
