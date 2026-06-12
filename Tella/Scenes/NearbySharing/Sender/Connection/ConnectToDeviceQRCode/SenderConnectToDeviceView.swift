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
    
    enum ConnectStep {
        case showQRCode
        case scanQRCode
    }
    
    @StateObject var viewModel: SenderConnectToDeviceViewModel
    @State var isBottomSheetShown : Bool = false
    @State var startScanning = PassthroughSubject<Bool, Never>()
    @State var step: ConnectStep = .showQRCode
    
    var body: some View {
        ZStack {
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            .onReceive(viewModel.$viewState) { state in
                handleViewState(state: state)
            }
            
            if viewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()
            switch step {
            case .showQRCode:
                CustomText(LocalizableNearbySharing.step1ShowSenderQr.localized,
                           style: .heading1Style,
                           alignment: .center)
                qrCodeStateView
                    .padding(.bottom, 28)
            case .scanQRCode:
                CustomText(LocalizableNearbySharing.step2ScanRecipientQr.localized,
                           style: .heading1Style,
                           alignment: .center)
                qrCodeScannerView
                    .padding(.bottom, 28)
            }
            recipientCantScanQRCodeButton
            CustomText(LocalizableNearbySharing.havingTrouble.localized, style: .body1Style)
            connectManuallyButton
            Spacer()
            bottomNavigationView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Step 1 → Step 2: Scan the recipient QR code
    var bottomNavigationView: some View {
        NavigationBottomView<SenderConnectToDeviceView>(
            shouldActivateNext: .constant(true),
            nextButtonAction: .destination,
            destination: SenderConnectToDeviceView(viewModel: viewModel, step: .scanQRCode),
            shouldHideNext: step == .scanQRCode,
            shouldHideBack: true
        )
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.connectToDevice.localized,
                             navigationBarType: .inline,
                             rightButtonType: .none)
    }
    
    @ViewBuilder
    var qrCodeStateView: some View {
        switch viewModel.qrCodeState {
        case .loading:
            CircularActivityIndicatory(isTransparent: true)
                .frame(width: 240, height: 240)
        case .loaded(let qrImage):
            qrCodeImageView(qrImage: qrImage)
        case .error(let error):
            CustomText(error, style: .body1Style)
                .frame(width: 240, height: 240)
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func qrCodeImageView(qrImage: UIImage) -> some View {
        Image(uiImage: qrImage)
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
    
    var qrCodeScannerView: some View {
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
    
    @ViewBuilder
    var recipientCantScanQRCodeButton: some View {
        if step == .showQRCode {
            TellaButtonView(title: "Scan Recipient QR code".uppercased(),
                            nextButtonAction: .destination,
                            isValid: .constant(true),
                            buttonRole: .secondary) {
                step = .scanQRCode
            }
                            .padding([.leading, .trailing], 80)
            
        }
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView( tryAction:  {
            startScanning.send(true)
            self.viewModel.observeScannedCode()
        })
        self.showBottomSheetView(content: content, isPresented: $isBottomSheetShown)
    }
    
    private func showIncompatibleVersionSheet() {
        isBottomSheetShown = true
        let content = ConfirmBottomSheet(
            titleText: LocalizableNearbySharing.incompatibleVersionTitle.localized,
            msgText: LocalizableNearbySharing.incompatibleVersionExpl.localized,
            actionText: LocalizableCommon.commonActionOk.localized,
            shouldHideSheet: false,
            didConfirmAction: {
                self.dismiss {
                    isBottomSheetShown = false
                    popTo(ViewClassType.nearbySharingMainView)
                }
            }
        )
        showBottomSheetView(content: content, isPresented: $isBottomSheetShown, tapToDismiss: false)
    }
    
    private func handleViewState(state: SenderConnectToDeviceViewAction) {
        switch state {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showIncompatibleVersion:
            showIncompatibleVersionSheet()
        case .showSenderHashVerification(let connectionInfo):
            guard let senderHash = viewModel.clientCertificateHash else { return }
            let verificationVM = ManuallyVerificationViewModel(
                participant: .sender,
                nearbySharingRepository: viewModel.nearbySharingRepository,
                connectionInfo: connectionInfo,
                mainAppModel: viewModel.mainAppModel,
                verificationRole: .senderHash(confirmAction: .acknowledgeOnly),
                certificateHashToDisplay: senderHash
            )
            navigateTo(destination: ManuallyVerificationView(viewModel: verificationVM))
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
