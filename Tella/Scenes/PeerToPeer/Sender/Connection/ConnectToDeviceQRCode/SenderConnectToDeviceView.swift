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
        VStack(alignment: .center, spacing: 12) {
            Spacer()
            CustomText(LocalizablePeerToPeer.scanCode.localized, style: .heading1Style)
            qrCodeView
                .padding(.bottom, 28)
            CustomText(LocalizablePeerToPeer.havingTrouble.localized, style: .body1Style)
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
                        destination: SenderConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyViewModel(peerToPeerRepository: viewModel.peerToPeerRepository, mainAppModel: viewModel.mainAppModel)),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }

    var bottomView: some View {
        BottomLockView<AnyView>(isValid: .constant(true),
                                nextButtonAction: .action,
                                shouldHideNext: true,
                                shouldHideBack: false)
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
            guard let sessionId = viewModel.sessionId else { return }
            let viewModel = P2PSendFilesViewModel(mainAppModel: viewModel.mainAppModel,
                                                  sessionId:sessionId,
                                                  peerToPeerRepository:viewModel.peerToPeerRepository)
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
