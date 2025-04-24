//
//  RecipientConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 07.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientConnectToDeviceView: View {
    
    @StateObject var viewModel: RecipientConnectToDeviceViewModel
    
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
    
    private var contentView: some View {
        VStack  {
            Spacer()
            VStack(spacing:12)  {
                CustomText(LocalizablePeerToPeer.showQrCode.localized,
                           style: .heading1Style,
                           alignment: .center)
                
                qrCodeStateView
                    .padding(.bottom, 28)
                CustomText(LocalizablePeerToPeer.havingTrouble.localized,
                           style: .body1Style,
                           alignment: .center)
                connectManuallyButton
            }
            Spacer()
            BackBottomView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }
    
    @ViewBuilder
    var qrCodeStateView: some View {
        switch viewModel.qrCodeState {
        case .loading:
            CircularActivityIndicatory(isTransparent:true)
                .frame(width: 240, height: 240)
        case .loaded(let connectionInfo):
            qrCodeImageView(connectionInfo: connectionInfo)
        case .error(let error):
            CustomText(error, style: .body1Style)
                .frame(width: 240, height: 240)
        }
    }
    
    func qrCodeImageView(connectionInfo:ConnectionInfo) -> some View {
        Image(uiImage: connectionInfo.generateQRCode(size: CGFloat(215)))
            .resizable()
            .scaledToFill()
            .frame(width: 215, height: 215)
            .padding(.all, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Styles.Colors.yellow, lineWidth: 8)
            )
    }
    
    var connectManuallyButton: some View {
        
        TellaButtonView(title: LocalizablePeerToPeer.connectManually.localized.uppercased(),
                        nextButtonAction: .destination,
                        destination: RecipientConnectToDeviceManuallyView(viewModel: RecipientConnectManuallyViewModel(certificateGenerator: viewModel.certificateGenerator, mainAppModel: viewModel.mainAppModel, server: viewModel.server,connectionInfo: viewModel.connectionInfo)),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
    
    private func handleViewState(state: RecipientConnectToDeviceViewState) {
        switch state {
        case .showReceiveFiles:
            self.navigateTo(destination: RecipientWaitingView())
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
}

#Preview {
    SenderConnectToDeviceView(viewModel: SenderConnectToDeviceViewModel(peerToPeerRepository:PeerToPeerRepository(),
                                                                        mainAppModel: MainAppModel.stub()))
}
