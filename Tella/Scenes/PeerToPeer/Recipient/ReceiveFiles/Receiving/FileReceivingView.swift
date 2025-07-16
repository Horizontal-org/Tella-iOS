//
//  FileReceivingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct FileReceivingView: View {
    @ObservedObject var viewModel: ReceiverFileTransferVM
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ZStack {
            FileTransferView(viewModel: viewModel)
        }.onReceive(viewModel.$viewAction) { action in
            handleViewAction(action:action)
        }
    }
    
    func showProgressView() {
        viewModel.progressFile = ProgressFile()
        
        sheetManager.showBottomSheet(modalHeight: 190,
                                     shouldHideOnTap: false,
                                     content: {
            
            ImportFilesProgressView(progress: viewModel.progressFile,
                                    importFilesProgressProtocol: ImportFilesProgress())
        })
    }
    
    func handleViewAction(action: TransferViewAction)  {
        switch action {
            
        case .transferIsFinished:
            showProgressView()
        case .shouldShowResults:
            let resultVM = P2PResultVM(transferredFiles: viewModel.transferredFiles,
                                       participant: .recipient)
            
            let resultView = P2PResultView(viewModel: resultVM, buttonAction: {
                self.popToRoot()
            })
            navigateTo(destination: resultView)
        default:
            break
        }
    }
}
//
//#Preview {
//    FileReceivingView(viewModel: FileTransferVM.stub())
//}
