//
//  SenderFileTransferView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct SenderFileTransferView: View {
    
    @ObservedObject var viewModel: SenderFileTransferVM
    @EnvironmentObject private var sheetManager: SheetManager
    private let delayTimeInSecond = 0.1
    var rootView: AnyClass = ViewClassType.reportMainView
    @State private var isBottomSheetShown : Bool = false
    
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
            reportDetails
            buttonView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.sendFiles.localized,
                             backButtonAction: {handleBackAction()})
    }
    
    private var reportDetails :some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                reportInformations
                
                Spacer()
                    .frame(height: 16)
                
                itemsListView
            }
        }.padding(EdgeInsets(top: 20, leading: 16, bottom: 70, trailing: 16))
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
    
    private var reportInformations: some View {
        Group {
            Text("")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            uploadProgressView
            
            Spacer()
                .frame(height: 16)
            
            Divider()
                .background(Color.white.opacity(0.2))
        }
    }
    
    private var uploadProgressView : some View {
        
        Group {
            
            Spacer()
                .frame(height: 8)
            
            Text(viewModel.percentUploadedInfo)
                .font(.custom(Styles.Fonts.italicRobotoFontName, size: 13))
                .foregroundColor(.white)
            Spacer()
                .frame(height: 4)
            
            Text(viewModel.uploadedFiles)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            if viewModel.percentUploaded > 0.0 {
                ProgressView("", value: viewModel.percentUploaded, total: 1)
                    .accentColor(.green)
            }
        }
    }
    
    private var itemsListView: some View {
        LazyVStack(spacing: 1) {
            ForEach($viewModel.progressFileItems, id: \.file.id) { file in
                OutboxDetailsItemView(item: file)
                    .frame(height: 60)
            }
        }
    }
    
    private func handleBackAction() {
        if viewModel.isSubmissionInProgress {
            self.showCancelUploadConfirmationView()
        } else {
            self.dismissView()
        }
    }
    
    private func dismissView() {
        DispatchQueue.main.asyncAfter(deadline:.now() + delayTimeInSecond, execute: {
            self.popTo(ViewClassType.peerToPeerMainView)
        })
    }
    
    private func showCancelUploadConfirmationView() {
        isBottomSheetShown = true
        let content = ConfirmBottomSheet(titleText: LocalizablePeerToPeer.stopSharingTitle.localized,
                                         msgText: LocalizablePeerToPeer.stopSharingSheetExpl.localized,
                                         cancelText: LocalizablePeerToPeer.stopSharingContinue.localized.uppercased(),
                                         actionText:LocalizablePeerToPeer.stopSharingStop.localized.uppercased(), didConfirmAction: {
            viewModel.stopServerListening()
            dismissView()
        }, didCancelAction: {
            self.dismiss()
        })
        
        self.showBottomSheetView(content: content, modalHeight: 192, isShown: $isBottomSheetShown)
    }
}


//#Preview {
//    SenderFileTransferView(viewModel: SenderFileTransferVM())
//}
