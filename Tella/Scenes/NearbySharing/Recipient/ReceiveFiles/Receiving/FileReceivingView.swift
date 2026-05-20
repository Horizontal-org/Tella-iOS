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
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }

    }
    
    func handleViewAction(action: TransferViewAction)  {
        switch action {
            
        case .shouldShowResults:
            let resultVM = NearbySharingResultVM(transferredFiles: viewModel.transferredFiles,
                                                 participant: .recipient)
            
            let resultView = NearbySharingResultView(viewModel: resultVM, buttonAction: {
                navigateTo(destination: getFileListView())
            })
            navigateTo(destination: resultView)
        default:
            break
        }
    }
    
    private func getFileListView() -> some View {
        FileListView(mainAppModel: viewModel.mainAppModel,
                     rootFile: viewModel.rootFile,
                     filterType: .all,
                     title: viewModel.rootFile?.name ?? "",
                     fileListType: .nearbySharing)
    }
}
//
//#Preview {
//    FileReceivingView(viewModel: FileTransferVM.stub())
//}
