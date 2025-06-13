//
//  P2PSendFilesView.swift
//  Tella
//
//  Created by RIMA on 25.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import Combine


struct SenderPrepareFileTransferView: View {
    
    @ObservedObject var viewModel: SenderPrepareFileTransferVM
    
    var body: some View {
        ZStack {
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            AddFilePhotoVideoPickerView(viewModel: viewModel.addFilesViewModel)
        }
        .overlay(AddFileCameraView(viewModel: viewModel.addFilesViewModel))
        .overlay(AddFileRecordView(viewModel: viewModel.addFilesViewModel))
        .onReceive(viewModel.$viewAction) { state in
            self.handleViewState(state: state)
        }
    }
    
    fileprivate var contentView: some View {
        switch viewModel.viewState {
        case .waiting:
            return AnyView(waitingView)
        case .prepareFiles:
            return AnyView(prepareFiles)
        }
    }
    
    fileprivate var waitingView: some View {
        VStack {
            CustomText(LocalizablePeerToPeer.senderWaitingReceipient.localized, style: .heading1Style)
            ResizableImage("clock").frame(width: 48, height: 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    fileprivate var prepareFiles: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            titleTextFieldView()
            
            AddFileGridView(viewModel: viewModel.addFilesViewModel, titleText: LocalizablePeerToPeer.selectFilesToSend.localized)
                .padding(.top, 24)
            
            Spacer()
            
            TellaButtonView(title: LocalizablePeerToPeer.sendFiles.localized.uppercased(),
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                             isValid: $viewModel.reportIsValid) {
                viewModel.prepareUpload()
            }.padding(.bottom, 20)
            
        }.padding(16)
    }
    
    fileprivate func titleTextFieldView() -> some View {
        return TextfieldView(fieldContent: $viewModel.title,
                             isValid: $viewModel.validTitle,
                             shouldShowError: .constant(false),
                             fieldType: .text,
                             placeholder: "Title",
                             shouldShowTitle: true)
        .frame(height: 78)
    }
    
    fileprivate var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.sendFiles.localized,
                             backButtonAction: {
            self.popTo(ViewClassType.peerToPeerMainView)
            self.viewModel.closeConnection()
        })
    }
    
    private func handleViewState(state: SenderPrepareFileTransferAction) {
        switch state {
        case .displaySendingFiles:
            self.navigateTo(destination: SenderFileTransferView(viewModel: SenderFileTransferVM(mainAppModel: viewModel.mainAppModel, repository: viewModel.peerToPeerRepository)))
            break
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .errorOccured:
            self.popTo(ViewClassType.peerToPeerMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        default:
            break
        }
    }
    
}
