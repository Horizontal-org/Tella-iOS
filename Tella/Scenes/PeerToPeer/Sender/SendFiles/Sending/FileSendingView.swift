//
//  FileSendingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct FileSendingView: View {
    
    @ObservedObject var viewModel: SenderFileTransferVM
 
    var body: some View {
        ZStack {
            FileTransferView(viewModel: viewModel)
        }.onReceive(viewModel.$viewAction) { newAction in
            handleViewAction(action: newAction)
        }
    }

    func handleViewAction(action: TransferViewAction)  {
        switch action {
            
        case .transferIsFinished:
            
            let resultVM = NearbySharingResultVM(transferredFiles: viewModel.transferredFiles,
                                       participant: .sender)
 
            let resultView = NearbySharingResultView(viewModel: resultVM)
            navigateTo(destination: resultView)
         default:
            break
        }
    }
}

//#Preview {
//    FileSendingView(viewModel: SenderFileTransferVM.stub())
//}
