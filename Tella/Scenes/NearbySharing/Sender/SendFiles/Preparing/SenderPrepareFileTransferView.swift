//
//  SenderPrepareFileTransferView.swift
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
    @State private var isInsufficientStorageSheetPresented = false
    @State private var isExitConfirmationSheetPresented = false
    
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
            CustomText(LocalizableNearbySharing.senderWaitingRecipient.localized, style: .heading1Style)
            ResizableImage("clock").frame(width: 48, height: 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    fileprivate var prepareFiles: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                
                titleTextFieldView()
                
                AddFileGridView(viewModel: viewModel.addFilesViewModel, titleText: LocalizableNearbySharing.selectFilesToSend.localized)
                    .padding(.top, 24)
                
                Spacer()
            }
            TellaButtonView(title: LocalizableNearbySharing.sendFiles.localized.uppercased(),
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
        NavigationHeaderView(title: LocalizableNearbySharing.sendFiles.localized,
                             backButtonAction: {
            showExitNearbySharingConfirmation()
        })
    }
    
    private func handleViewState(state: SenderPrepareFileTransferAction) {
        switch state {
        case .displaySendingFiles:
            let session = self.viewModel.session
            let viewModel = SenderFileTransferVM(mainAppModel: self.viewModel.mainAppModel,
                                                 repository: self.viewModel.nearbySharingRepository,
                                                 session: session)
            self.navigateTo(destination: FileSendingView(viewModel: viewModel))
        case .showToast(let message):
            Toast.displayToast(message: message)
        case .showRecipientInsufficientStorageSheet:
            viewModel.viewAction = .none
            showRecipientInsufficientStorageBottomSheet()
        case .errorOccured:
            self.popTo(ViewClassType.nearbySharingMainView)
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        default:
            break
        }
    }
    
    private func showExitNearbySharingConfirmation() {
        isExitConfirmationSheetPresented = true
        let content = ConfirmBottomSheet(
            titleText: LocalizableNearbySharing.exitProgressSheetTitle.localized,
            msgText: LocalizableNearbySharing.exitProgressSheetExpl.localized,
            cancelText: LocalizableNearbySharing.cancel.localized.uppercased(),
            actionText: LocalizableNearbySharing.exitProgressExitAction.localized,
            shouldHideSheet: false,
            didConfirmAction: {
                self.dismiss {
                    self.isExitConfirmationSheetPresented = false
                    self.popTo(ViewClassType.nearbySharingMainView)
                    self.viewModel.closeConnection()
                }
            },
            didCancelAction: {
                self.dismiss {
                    self.isExitConfirmationSheetPresented = false
                }
            }
        )
        self.showBottomSheetView(content: content, isPresented: $isExitConfirmationSheetPresented)
    }
    
    private func showRecipientInsufficientStorageBottomSheet() {
        isInsufficientStorageSheetPresented = true
        let content = ConfirmBottomSheet(
            titleText: LocalizableNearbySharing.transferFailedSheetTitle.localized,
            msgText: LocalizableNearbySharing.recipientInsufficientStorageSheetExpl.localized,
            actionText: LocalizableNearbySharing.insufficientStorageSheetAction.localized,
            shouldHideSheet: false,
            didConfirmAction: {
                self.dismiss {
                    self.isInsufficientStorageSheetPresented = false
                }
            }
        )
        self.showBottomSheetView(content: content, isPresented: $isInsufficientStorageSheetPresented)
    }
}
