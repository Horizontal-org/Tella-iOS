//
//  FileTransfertView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import Combine

struct TransferProgressView: View {
    
    @ObservedObject var viewModel : ProgressViewModel
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                reportInformations
                
                Spacer()
                    .frame(height: 16)
                
                itemsListView
            }
        }.padding(EdgeInsets(top: 20, leading: 16, bottom: 70, trailing: 16))
    }
    
    
    private var reportInformations: some View {
        Group {
            
            CustomText(viewModel.title, style: .subheading1Style)
            
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
            
            CustomText(viewModel.percentTransferredText,
                       style: .body2ItalicStyle)
            
            Spacer()
                .frame(height: 4)
            
            CustomText(viewModel.transferredFilesSummary,
                       style: .body2Style)
            
            if viewModel.percentTransferred > 0.0 {
                ProgressView("", value: viewModel.percentTransferred, total: 1)
                    .accentColor(.green)
            }
        }
    }
    
    private var itemsListView: some View {
        LazyVStack(spacing: 1) {
            ForEach(viewModel.progressFileItems, id: \.vaultFile.id) { file in
                OutboxDetailsItemView(item: file)
                    .frame(height: 60)
            }
        }
    }
}

#Preview {
    TransferProgressView(viewModel: ProgressViewModel.stub())
}
