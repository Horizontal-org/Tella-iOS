//
//  WifiConnetionView.swift
//  Tella
//
//  Created by RIMA on 31.01.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct GetConnectedView: View {
    
    @StateObject var viewModel: GetConnectedViewModel
    @StateObject var mainAppModel: MainAppModel
    @State var isCheckboxOn = false
    
    struct TipsToConnectButton : IconTextButtonConfig {
        var title = LocalizableNearbySharing.tipsToConnect.localized.uppercased()
        var description = LocalizableNearbySharing.tipsToConnectExpl.localized
        var imageName = "help.yellow"
    }
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            topView
            DividerView()
            sameNetworkView
            Spacer()
            bottomView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 20)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.getConnected.localized ,
                             navigationBarType: .inline,
                             rightButtonType: .none)
    }
    
    var lineView: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white.opacity(0.2))
    }
    
    var topView: some View {
        VStack(alignment: .center, spacing: 12) {
            
            Image("nearby-sharing.connect")
            
            CustomText(LocalizableNearbySharing.getConnectedSubhead.localized,
                       style: .heading1Style,
                       alignment: .center)
            
            CustomText(LocalizableNearbySharing.getconnectedExpl.localized,
                       style: .body1Style,
                       alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            IconTextButton(buttonConfig: TipsToConnectButton(),
                           destination: TipsToConnectView())
        }
    }
    
    var sameNetworkView: some View {
        HStack {
            CustomText(LocalizableNearbySharing.sameNetworkExpl.localized,
                       style: .body1Style)
            Spacer()
            ResizableImage(isCheckboxOn ? "checkbox.on" : "checkbox.off")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    isCheckboxOn.toggle()
                }
            
        }.cardModifier()
    }
    
    var bottomView: some View {
        NavigationBottomView<AnyView>(shouldActivateNext: $isCheckboxOn,
                                      nextButtonAction: .action,
                                      shouldHideBack: true,
                                      nextAction: {
            switch viewModel.participant {
            case .sender:
                let senderConnectToDeviceViewModel = SenderConnectToDeviceViewModel(nearbySharingRepository:NearbySharingRepository(),
                                                                                    mainAppModel: mainAppModel)
                navigateTo(destination: SenderConnectToDeviceView(viewModel:senderConnectToDeviceViewModel))
            case .recipient:
                let recipientConnectToDeviceViewModel = RecipientConnectToDeviceViewModel(certificateGenerator: CertificateGenerator(),
                                                                                          mainAppModel: mainAppModel)
                navigateTo(destination: RecipientConnectToDeviceView(viewModel: recipientConnectToDeviceViewModel))
            }
        })
    }
    
    func showTipsToConnectView() {
        self.navigateTo(destination: TipsToConnectView())
    }
}

#Preview {
    GetConnectedView(viewModel: GetConnectedViewModel(participant: .recipient,
                                                      mainAppModel: MainAppModel.stub()),
                     mainAppModel: MainAppModel.stub())
}


