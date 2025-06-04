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
                .padding(.bottom, 8)
            infoView
            Spacer()
            buttonsView
        }.scrollOnOverflow()
            .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectManually.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             backButtonAction: {self.popToRoot()}, //TODO: TO Check
                             rightButtonType: .none)
    }
    
    var topView: some View {
        ServerConnectionHeaderView(
            title: LocalizablePeerToPeer.verificationSubhead.localized,
            imageIconName: "device",
            subtitleTextAlignment: .leading)
    }
    
    
    var infoView: some View {
        participantInfoView(
            part1Text: viewModel.participant == .sender
            ? LocalizablePeerToPeer.verificationSenderPart1.localized
            : LocalizablePeerToPeer.verificationReceipientPart1.localized,
            
            part2Text: viewModel.participant == .sender
            ? LocalizablePeerToPeer.verificationSenderPart2.localized
            : LocalizablePeerToPeer.verificationReceipientPart2.localized
        )
    }
    
    private func participantInfoView(part1Text: String, part2Text: String) -> some View {
        VStack(alignment: .center, spacing: 24) {
            CustomText(part1Text, style: .body1Style)
            
            CustomText(viewModel.connectionInfo.certificateHash ?? "", style: .body1Style)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardModifier()
            
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
        TellaButtonView(title: LocalizablePeerToPeer.verificationConfirm.localized.uppercased(),
                                  nextButtonAction: .action,
                                  buttonType: .yellow,
                                  isValid: $viewModel.shouldShowConfirmButton) {
            viewModel.confirmAction()
        }
    }
    
    var discardButton: some View {
        TellaButtonView(title: LocalizablePeerToPeer.verificationDiscard.localized.uppercased(),
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
            guard let sessionId = viewModel.sessionId,
                  let peerToPeerRepository = viewModel.peerToPeerRepository
            else {
                return
            }
            let viewModel = SenderPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel,
                                                        sessionId:sessionId,
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
            guard let server = viewModel.server else { return }
            self.navigateTo(destination: RecipientFileTransferView(viewModel: RecipientPrepareFileTransferVM(mainAppModel: viewModel.mainAppModel, server: server)))
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
                                                                      mainAppModel: MainAppModel.stub(),
                                                                      server: PeerToPeerServer()))
}
