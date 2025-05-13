//
//  RecipientConnectToDeviceManuallyView.swift
//  Tella
//
//  Created by RIMA on 10.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientConnectToDeviceManuallyView: View {
    
    @StateObject var viewModel: RecipientConnectManuallyViewModel
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        
        .onReceive(viewModel.$viewState) { state in
            handleViewState(state: state)
        }
    }
    
    var contentView: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                topView
                cardsView
            }
            Spacer()
            BackBottomView()
        }
        .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             backButtonAction: {self.popToRoot()}, //TO Check
                             rightButtonType: .none)
    }
    
    var topView: some View {
        ServerConnectionHeaderView(
            title: LocalizablePeerToPeer.showDeviceInformation.localized,
            subtitle: LocalizablePeerToPeer.sendInputDesc.localized,
            imageIconName: "device",
            subtitleTextAlignment: .center)
    }
    
    var cardsView: some View  {
        VStack(spacing: 8) {
            CardItemView(title: LocalizablePeerToPeer.ipAddress.localized, subtitle: viewModel.ipAddress)
            CardItemView(title: LocalizablePeerToPeer.pin.localized, subtitle: viewModel.pin)
            CardItemView(title: LocalizablePeerToPeer.port.localized, subtitle: viewModel.port)
        }
    }
    
    private func handleViewState(state: RecipientConnectToDeviceViewState) {
        switch state {
        case .showVerificationHash:
            guard let connectionInfo = viewModel.connectionInfo else { return  }
            let viewModel = ManuallyVerificationViewModel(participant:.recipient,
                                                          connectionInfo: connectionInfo,
                                                          mainAppModel: viewModel.mainAppModel,
                                                          server: viewModel.server)
            self.navigateTo(destination: ManuallyVerificationView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
}
