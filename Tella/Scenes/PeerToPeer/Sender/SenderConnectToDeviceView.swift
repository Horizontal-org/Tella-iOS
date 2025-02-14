//
//  ConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SenderConnectToDeviceView: View {
    
    @StateObject var viewModel: SenderConnectToDeviceViewModel
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            VStack {
                RegularText(LocalizablePeerToPeer.scanCode.localized, size: 18)
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
        ZStack{
            QRCodeScannerView(scannedCode: $viewModel.scannedCode)
                .cornerRadius(12)
                .padding(.all,4)
            ResizableImage("qrCode.icon")
            
        }.frame(width: 248, height: 248)
    }
    
    var connectManuallyButton: some View {
        TellaButtonView(title: LocalizablePeerToPeer.connectManually.localized.uppercased(),
                        nextButtonAction: .destination,
                        destination: SenderConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyViewModel()),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
}

#Preview {
    SenderConnectToDeviceView(viewModel: SenderConnectToDeviceViewModel())
}
