//
//  RecipientConnectToDeviceManuallyView.swift
//  Tella
//
//  Created by RIMA on 10.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
    
    var contentView: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                topView
                cardsView
            }
            Spacer()
        }
        .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             rightButtonType: .none)
    }
    
    var topView: some View {
        ServerConnectionHeaderView(
            title: LocalizableNearbySharing.showDeviceInformation.localized,
            subtitle: LocalizableNearbySharing.sendInputDesc.localized,
            imageIconName: "device",
            subtitleTextAlignment: .center)
    }
    
    var cardsView: some View  {
        VStack(spacing: 8) {
            CardItemView(title: LocalizableNearbySharing.ipAddress.localized, subtitle: viewModel.ipAddress)
            CardItemView(title: LocalizableNearbySharing.pin.localized, subtitle: viewModel.pin)
            CardItemView(title: LocalizableNearbySharing.port.localized, subtitle: viewModel.port)
        }
    }
    
    private func handleViewState(state: RecipientConnectToDeviceViewAction) {
        switch state {
        case .showVerificationHash:
            guard let connectionInfo = viewModel.connectionInfo else { return }
            let viewModel = ManuallyVerificationViewModel(participant:.recipient,
                                                          connectionInfo: connectionInfo,
                                                          mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: ManuallyVerificationView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
}
