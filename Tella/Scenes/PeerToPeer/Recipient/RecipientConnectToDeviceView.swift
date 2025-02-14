//
//  RecipientConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 07.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientConnectToDeviceView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            VStack {
                RegularText(LocalizablePeerToPeer.showQrCode.localized, size: 18)
                    .padding(.top, 74)
                
                qrCodeView.padding(.bottom, 40)
                RegularText(LocalizablePeerToPeer.havingTrouble.localized)
                connectManuallyButton
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }
    var qrCodeView: some View {
        Rectangle().fill(Styles.Colors.yellow).cornerRadius(8)
            .frame(width: 248, height: 248)
        //TODO: Add a QRCode reader
    }
    
    var connectManuallyButton: some View {
        TellaButtonView(title: LocalizablePeerToPeer.connectManually.localized.uppercased(),
                        nextButtonAction: .destination,
                        destination: RecipientWaitingView() /*RecipientConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyViewModel())*/,
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
}

#Preview {
    SenderConnectToDeviceView()
}
