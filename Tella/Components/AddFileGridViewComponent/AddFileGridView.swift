//
//  AddFileGridView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct AddFileGridView: View {
    
    private let gridLayout: [GridItem] = [GridItem(spacing: 12),
                                          GridItem(spacing: 12),
                                          GridItem(spacing: 12)]
    
    private let gridItemHeight = (UIScreen.screenWidth - 64.0) / 3
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var titleText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            attachFilesTextView
            
            itemsGridView
            
            AddFileBottomSheetView(viewModel: viewModel) {
                Image("add.file.icon")
            }
        }
    }
    
    
    var attachFilesTextView: some View {
        CustomText(titleText, style: .body1Style)
    }
    
    var itemsGridView: some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 12) {
            ForEach(viewModel.files.sorted{$0.created < $1.created}, id: \.id) { file in
                AddFileGridItemView(file: file, viewModel: viewModel)
                    .frame(height: gridItemHeight)
            }
        }
    }
    }
