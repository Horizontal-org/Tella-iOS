//
//  RecipientConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 07.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct RecipientConnectToDeviceView: View {
    
    @StateObject var viewModel: RecipientConnectToDeviceViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onReceive(viewModel.$viewAction) { state in
            handleViewState(state: state)
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
    
    private var contentView: some View {
        VStack  {
            Spacer()
            VStack(spacing:12)  {
                CustomText(LocalizableNearbySharing.showQrCode.localized,
                           style: .heading1Style,
                           alignment: .center)
                
                qrCodeStateView
                    .padding(.bottom, 28)
                CustomText(LocalizableNearbySharing.havingTrouble.localized,
                           style: .body1Style,
                           alignment: .center)
                connectManuallyButton
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonAction: {
            presentationMode.wrappedValue.dismiss()
            viewModel.stopServerListening()
        },
                             rightButtonType: .none)
    }
    
    @ViewBuilder
    var qrCodeStateView: some View {
        switch viewModel.qrCodeState {
        case .loading:
            CircularActivityIndicatory(isTransparent:true)
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
    func qrCodeImageView(qrImage:UIImage) -> some View {
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
    
    var connectManuallyButton: some View {
        
        let viewModel = RecipientConnectManuallyViewModel(certificateGenerator: viewModel.certificateGenerator,
                                                          mainAppModel: viewModel.mainAppModel,
                                                          connectionInfo: viewModel.connectionInfo)
        
        return TellaButtonView(title: LocalizableNearbySharing.connectManually.localized.uppercased(),
                               nextButtonAction: .destination,
                               destination: RecipientConnectToDeviceManuallyView(viewModel:viewModel),
                               isValid: .constant(true),
                               buttonRole: .secondary)
        .padding([.leading, .trailing], 80)
    }
    
    private func handleViewState(state: RecipientConnectToDeviceViewAction) {
        switch state {
        case .showReceiveFiles:
            let fileTransferVM = RecipientPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: RecipientFileTransferView(viewModel:fileTransferVM))
        case .errorOccured:
            self.popTo(ViewClassType.nearbySharingMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
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
