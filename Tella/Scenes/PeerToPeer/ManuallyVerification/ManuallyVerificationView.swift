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
        NavigationHeaderView(title: LocalizableNearbySharing.connectManually.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             backButtonAction: {self.popTo(ViewClassType.peerToPeerMainView)},
                             rightButtonType: .none)
    }
    
    var topView: some View {
        Image("device")
            .padding(.bottom, 16)
    }
    
    var infoView: some View {
        participantInfoView(
            part1Text: viewModel.participant == .sender
            ? LocalizableNearbySharing.verificationSenderPart1.localized
            : LocalizableNearbySharing.verificationRecipientPart1.localized,
            
            part2Text: viewModel.participant == .sender
            ? LocalizableNearbySharing.verificationSenderPart2.localized
            : LocalizableNearbySharing.verificationRecipientPart2.localized
        )
    }
    
    private func participantInfoView(part1Text: String, part2Text: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            
            CustomText(viewModel.connectionInfo.certificateHash?.formatHash() ?? "",
                       style: .body1Style,
                       alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .cardModifier()
            
            CustomText(part1Text, style: .body1Style)
            
            CustomText(part2Text, style: .body1Style)
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
                        isValid: .constant(true)) {
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
            popTo(ViewClassType.peerToPeerMainView)
        }
        self.showBottomSheetView(content: content,
                                 modalHeight: 192,
                                 isShown: $isBottomSheetShown,
                                 shouldHideOnTap:false)
    }
    
    private func handleSenderViewAction(action: SenderConnectToDeviceViewAction) {
        switch action {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showSendFiles:
            guard let session = viewModel.session,
                  let peerToPeerRepository = viewModel.peerToPeerRepository
            else {
                return
            }
            let viewModel = SenderPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel,
                                                        session: session,
                                                        peerToPeerRepository:peerToPeerRepository)
            self.navigateTo(destination: SenderPrepareFileTransferView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .discardAndStartOver:
            self.popTo(ViewClassType.peerToPeerMainView)
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
            self.popTo(ViewClassType.peerToPeerMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .discardAndStartOver:
            self.popTo(ViewClassType.peerToPeerMainView)
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
