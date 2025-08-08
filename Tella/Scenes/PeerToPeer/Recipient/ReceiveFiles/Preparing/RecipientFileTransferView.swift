//
//  RecipientWaitingView.swift
//  Tella
//
//  Created by RIMA on 14.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct RecipientFileTransferView: View {
    
    @StateObject var viewModel : RecipientPrepareFileTransferVM
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onReceive(viewModel.$viewAction) { state in
            handleViewState(state: state)
        }
    }
    
    var contentView: some View {
        switch  viewModel.viewState {
        case .waitingRequest:
            return AnyView(waitingView)
        case .awaitingAcceptance:
            return AnyView(awaitingAcceptanceView)
        }
    }
    
    var waitingView: some View {
        VStack {
            CustomText(LocalizableNearbySharing.waitingForSenderDesc.localized, style: .heading1Style)
            ResizableImage("clock").frame(width: 48, height: 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.receiveFiles.localized,
                             navigationBarType: .inline,
                             backButtonAction: {
            self.popTo(ViewClassType.nearbySharingMainView)
            viewModel.stopServerListening()
        },
                             rightButtonType: .none)
    }
    
    var awaitingAcceptanceView: some View {
        VStack{
            Spacer().frame(height: 100)
            ResizableImage("folders.icon").frame(width: 109, height: 109)
            
            CustomText(String(format: LocalizableNearbySharing.senderRequestFilesNumberDesc.localized, viewModel.files.count), style: .heading1Style)
                .padding(.bottom, 16)
            
            CustomText(LocalizableNearbySharing.requestQuestion.localized, style: .body1Style)
            
                .padding(.bottom, 48)
            VStack(spacing: 16) {
                TellaButtonView(title: LocalizableNearbySharing.accept.localized.uppercased(),
                                nextButtonAction: .action,
                                buttonType: .yellow,
                                isValid: .constant(true)) {
                    viewModel.respondToFileUpload(acceptance: true)
                }
                TellaButtonView(title: LocalizableNearbySharing.reject.localized.uppercased(),
                                nextButtonAction: .action,
                                isValid: .constant(true)) {
                    viewModel.respondToFileUpload(acceptance: false)
                }
                
            }.frame(height: 125)
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    
    private func handleViewState(state: RecipientPrepareFileTransferAction) {
        switch state {
        case .displayFileTransferView:
            guard let viewModel = ReceiverFileTransferVM(mainAppModel: self.viewModel.mainAppModel) else { return }
            self.navigateTo(destination: FileReceivingView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .errorOccured:
            self.popTo(ViewClassType.nearbySharingMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        default:
            break
        }
    }
}

#Preview {
    RecipientFileTransferView(viewModel: RecipientPrepareFileTransferVM.stub())
}
