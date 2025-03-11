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
            
            VStack(spacing: 12) {
                TellaButtonView(title: LocalizablePeerToPeer.sendFiles.localized.uppercased(),
                                nextButtonAction: .destination,
                                destination: WifiConnetionView(viewModel: WifiConnetionViewModel(participent: .sender,
                                                                                                 mainAppModel: mainAppModel),
                                                               mainAppModel: mainAppModel),
                                isValid: .constant(true))
                .frame(height: 54)
                
                TellaButtonView(title: LocalizablePeerToPeer.receiveFiles.localized.uppercased(),
                                nextButtonAction: .destination,
                                destination: WifiConnetionView(viewModel: WifiConnetionViewModel(participent: .recipient,
                                                                                                 mainAppModel: mainAppModel),
                                                               mainAppModel: mainAppModel),
                                isValid: .constant(true))
                .frame(height: 54)
            }
            
            
            learnMoreView.padding()
            
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizablePeerToPeer.nearbySharingSubhead.localized,
            subtitle: LocalizablePeerToPeer.nearbySharingExpl.localized,
            imageIconName: "p2p.main",
            subtitleTextAlignment: .leading)
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
    
}

#Preview {
    PeerToPeerMainView(mainAppModel: MainAppModel.stub())
}
