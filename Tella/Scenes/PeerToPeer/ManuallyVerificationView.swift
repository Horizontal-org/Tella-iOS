//
//  ManuallyVerificationView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ManuallyVerificationView: View {
    
    @ObservedObject var viewModel: ManuallyVerificationViewModel
    
    @State var isBottomSheetShown : Bool = false
    
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
                             backButtonAction: {self.popToRoot()}, //TO Check
                             rightButtonType: .none)
    }
    
    var topView: some View {
        VStack(alignment: .center,spacing: 8) {
            ResizableImage("device").frame(width: 120, height: 120)
            CustomText(LocalizablePeerToPeer.verificationSubhead.localized, style: .heading1Font)
        }
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
            CustomText(part1Text, style: .body1Font)
            
            CustomText(viewModel.connectionInfo.certificateHash ?? "", style: .body1Font)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardModifier()
            
            CustomText(part2Text, style: .body1Font)
        }
    }
    
    var buttonsView: some View {
        VStack(spacing: 17) {
            if viewModel.participant == .sender {
                confirmButton
            }
            discardButton
        }.padding([.top,.bottom],16)
    }
    
    var confirmButton: some View {
        TellaButtonView<AnyView> (title: LocalizablePeerToPeer.verificationConfirm.localized.uppercased(),
                                  nextButtonAction: .action,
                                  buttonType: .yellow,
                                  isValid: .constant(true)) {
            viewModel.register()
        }
    }
    
    var discardButton: some View {
        TellaButtonView<AnyView>(title: LocalizablePeerToPeer.verificationDiscard.localized.uppercased(),
                                 nextButtonAction: .action,
                                 isValid: .constant(true)) {
            // TODO: Handle this button action : pop view and close server ?
        }
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView()
        self.showBottomSheetView(content: content, modalHeight: 192, isShown: $isBottomSheetShown)
    }
    
    private func handleViewState(state: SenderConnectToDeviceViewState) {
        switch state {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showSendFiles:
            guard let sessionId = viewModel.sessionId,
                  let peerToPeerRepository = viewModel.peerToPeerRepository
            else {
                return
            }
            let viewModel = P2PSendFilesViewModel(mainAppModel: viewModel.mainAppModel,
                                                  sessionId:sessionId,
                                                  peerToPeerRepository:peerToPeerRepository)
            self.navigateTo(destination: P2PSendFilesView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
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
