//
//  ConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
            CustomText(LocalizableNearbySharing.scanCode.localized, style: .heading1Style)
            qrCodeView
                .padding(.bottom, 28)
            CustomText(LocalizableNearbySharing.havingTrouble.localized, style: .body1Style)
            connectManuallyButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.connectToDevice.localized,
                             navigationBarType: .inline,
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
        TellaButtonView(title: LocalizableNearbySharing.connectManually.localized.uppercased(),
                        nextButtonAction: .destination,
                        destination: SenderConnectToDeviceManuallyView(viewModel: ConnectToDeviceManuallyVM(nearbySharingRepository: viewModel.nearbySharingRepository, mainAppModel: viewModel.mainAppModel)),
                        isValid: .constant(true),
                        buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView( tryAction:  {
            startScanning.send(true)
            self.viewModel.observeScannedCode()
        })
        self.showBottomSheetView(content: content, isPresented: $isBottomSheetShown)
    }
    
    private func handleViewState(state: SenderConnectToDeviceViewAction) {
        switch state {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showSendFiles:
            guard let session = viewModel.session else { return }
            let viewModel = SenderPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel,
                                                        session:session,
                                                        nearbySharingRepository:viewModel.nearbySharingRepository)
            self.navigateTo(destination: SenderPrepareFileTransferView(viewModel: viewModel ))
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
}

#Preview {
    SenderConnectToDeviceView(viewModel: SenderConnectToDeviceViewModel(nearbySharingRepository:NearbySharingRepository(),
                                                                        mainAppModel: MainAppModel.stub()))
}
