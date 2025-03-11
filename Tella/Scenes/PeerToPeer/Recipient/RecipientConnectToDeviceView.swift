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
    }
    
    private var contentView: some View {
        VStack {
            RegularText(LocalizablePeerToPeer.showQrCode.localized, size: 18)
                .padding(.top, 74)
            qrCodeStateView.padding(.bottom, 40)
            RegularText(LocalizablePeerToPeer.havingTrouble.localized)
            connectManuallyButton
            Spacer()
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
                .frame(width: 160, height: 160)
        case .loaded(let qrCodeInfos):
            qrCodeImageView(qrCodeInfos: qrCodeInfos)
        case .error(let error):
            RegularText(error, size: 14)
                .frame(width: 160, height: 160)
        }
    }
    
    func qrCodeImageView(qrCodeInfos:QRCodeInfos) -> some View {
        Image(uiImage: qrCodeInfos.generateQRCode())
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 160)
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
                        destination: RecipientConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyViewModel()),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
}

#Preview {
    SenderConnectToDeviceView(viewModel: SenderConnectToDeviceViewModel())
}
