//
//  ManuallyVerificationView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ManuallyVerificationView: View {
    
    @ObservedObject var viewModel: ManuallyVerificationViewModel
    
    @State var isBottomSheetShown : Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onReceive(viewModel.$senderViewAction) { action in
            handleSenderViewAction(action: action)
        }
        .onReceive(viewModel.$recipientViewAction) { action in
            handleRecipientViewAction(action: action)
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
    
    var contentView: some View {
        VStack {
            topView
            infoView
            Spacer()
            buttonsView
        }.scrollOnOverflow()
            .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.verificationAppBar.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             backButtonAction: {self.popTo(ViewClassType.nearbySharingMainView)},
                             rightButtonType: .none)
    }
    
    var topView: some View {
        Image("device")
            .padding(.bottom, 16)
    }
    
    var infoView: some View {
        
        let verificationSenderString = LocalizableNearbySharing.verificationSenderPart1.localized.addTwolines + LocalizableNearbySharing.verificationSenderPart2.localized
        
        let verificationRecipientString = LocalizableNearbySharing.verificationRecipientPart1.localized.addTwolines + LocalizableNearbySharing.verificationRecipientPart2.localized
        
        return participantInfoView(
            text: viewModel.participant == .sender
            ? verificationSenderString
            : verificationRecipientString
        )
    }
    
    private func participantInfoView(text: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            
            CustomText(viewModel.connectionInfo.certificateHash?.formatHash() ?? "",
                       style: .body1Style,
                       alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .cardModifier()
            
            CustomText(text, style: .body1Style)
        }
    }
    
    var buttonsView: some View {
        VStack(spacing: 17) {
            confirmButton
            discardButton
        }.padding([.top,.bottom],16)
    }
    
    var confirmButton: some View {
        TellaButtonView(title: viewModel.confirmButtonTitle.uppercased(),
                        nextButtonAction: .action,
                        buttonType: .yellow,
                        isValid: $viewModel.shouldEnableConfirmButton) {
            viewModel.confirmAction()
        }.disabled(!viewModel.shouldEnableConfirmButton)
    }
    
    var discardButton: some View {
        TellaButtonView(title: LocalizableNearbySharing.verificationDiscard.localized.uppercased(),
                        nextButtonAction: .action,
                        isValid: .constant(true)) {
            viewModel.discardAction()
        }
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView {
            isBottomSheetShown = false
            popTo(ViewClassType.nearbySharingMainView)
        }
        self.showBottomSheetView(content: content,
                                 isPresented: $isBottomSheetShown,
                                 tapToDismiss: false)
    }
    
    private func handleSenderViewAction(action: SenderConnectToDeviceViewAction) {
        switch action {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showSendFiles:
            guard let session = viewModel.session,
                  let nearbySharingRepository = viewModel.nearbySharingRepository
            else {
                return
            }
            let viewModel = SenderPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel,
                                                        session: session,
                                                        nearbySharingRepository:nearbySharingRepository)
            self.navigateTo(destination: SenderPrepareFileTransferView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .discardAndStartOver:
            self.popTo(ViewClassType.nearbySharingMainView)
        default:
            break
        }
    }
    
    private func handleRecipientViewAction(action: RecipientConnectToDeviceViewAction) {
        switch action {
        case .showReceiveFiles:
            let viewModel = RecipientPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: RecipientFileTransferView(viewModel: viewModel))
        case .errorOccured:
            self.popTo(ViewClassType.nearbySharingMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .discardAndStartOver:
            self.popTo(ViewClassType.nearbySharingMainView)
        default:
            break
        }
    }
}

#Preview {
    ManuallyVerificationView(viewModel: ManuallyVerificationViewModel(participant: .recipient,
                                                                      connectionInfo: ConnectionInfo.stub(),
                                                                      mainAppModel: MainAppModel.stub()))
}
