//
//  FileTransferView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct FileTransferView: View {
    
    @ObservedObject var viewModel: FileTransferVM
    
    @State private var isBottomSheetShown : Bool = false
    private let delayTimeInSecond = 0.1
    
    var body: some View {
        
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            if viewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
    }
    
    var contentView : some View {
        ZStack {
            if let progressViewModel = viewModel.progressViewModel {
                TransferProgressView(viewModel: progressViewModel)
            }
            
            if viewModel.viewAction == .none {
                buttonView
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: viewModel.title,
                             backButtonAction: {handleBackAction()})
    }
    
    private var buttonView :some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                TellaButtonView(title: LocalizablePeerToPeer.cancel.localized.uppercased(),
                                nextButtonAction: .action,
                                isValid: .constant(true),
                                buttonRole: .secondary) {
                    showCancelUploadConfirmationView()
                }.frame(width: 132)
                    .padding(.trailing, 22)
            }
        }
    }
    
    private func handleBackAction() {
        self.showCancelUploadConfirmationView()
    }
    
    private func dismissView() {
        self.popTo(ViewClassType.peerToPeerMainView)
    }
    
    private func showCancelUploadConfirmationView() {
        isBottomSheetShown = true
        let content = ConfirmBottomSheet(titleText: viewModel.bottomSheetTitle,
                                         msgText: viewModel.bottomSheetMessage,
                                         cancelText: LocalizablePeerToPeer.continueSharing.localized.uppercased(),
                                         actionText:LocalizablePeerToPeer.stopSharing.localized.uppercased(),
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            self.dismiss()
            viewModel.stopTask()
        }, didCancelAction: {
            self.dismiss()
        })
        self.showBottomSheetView(content: content, modalHeight: 192, isShown: $isBottomSheetShown)
    }
}

//#Preview {
//    FileTransferView(viewModel: SenderFileTransferVM())
//}
