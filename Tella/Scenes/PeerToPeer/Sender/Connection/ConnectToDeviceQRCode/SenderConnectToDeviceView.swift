//
//  ConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine

struct SenderConnectToDeviceView: View {
    
    @StateObject var viewModel: SenderConnectToDeviceViewModel
    @State var isBottomSheetShown : Bool = false
    @State var startScanning = PassthroughSubject<Bool, Never>()
    
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
            RegularText(LocalizablePeerToPeer.scanCode.localized, size: 18)
                .padding(.top, 74)
            
            qrCodeView.padding(.bottom, 40)
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
    var qrCodeView: some View {
        ZStack{
            QRCodeScannerView(scannedCode: $viewModel.scannedCode,startScanning: startScanning)
                .cornerRadius(12)
                .padding(.all,4)
            ResizableImage("qrCode.icon")
            
        }.frame(width: 248, height: 248)
    }
    
    var connectManuallyButton: some View {
        TellaButtonView(title: LocalizablePeerToPeer.connectManually.localized.uppercased(),
                        nextButtonAction: .destination,
                        destination: SenderConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyViewModel(peerToPeerRepository: viewModel.peerToPeerRepository)),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView( tryAction:  {
            startScanning.send(true)  }
        )
        self.showBottomSheetView(content: content, modalHeight: 192, isShown: $isBottomSheetShown)
    }
    
    private func handleViewState(state: SenderConnectToDeviceViewState) {
        switch state {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showSendFiles:
            let viewModel = P2PSendFilesViewModel(mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: P2PSendFilesView(viewModel: viewModel ))
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
