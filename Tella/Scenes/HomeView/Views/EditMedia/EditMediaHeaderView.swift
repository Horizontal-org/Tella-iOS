//
//  EditMediaHeaderView.swift
//  Tella
//
//  Created by RIMA on 19.11.24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI


struct EditMediaHeaderView: View {
    @ObservedObject var viewModel: EditMediaViewModel
    @State private var isBottomSheetShown : Bool = false
    
    var body: some View {
        
        NavigationHeaderView(title: viewModel.headerTitle,
                             backButtonAction: {self.closeView()},
                             trailingButtonAction: { viewModel.trim() },
                             trailingButton: viewModel.isDurationHasChanged() ? .editFile : .none)
    }
    
    private func closeView() {
        viewModel.isPlaying = false
        if viewModel.isDurationHasChanged() {
            cancelAction()
        }else  {
            self.dismiss()
        }
    }
    private func cancelAction() {
        isBottomSheetShown = true
        let content = EditFileCancelBottomSheet( saveAction:  { viewModel.trim() })
        self.showBottomSheetView(content: content, modalHeight: 171, isShown: $isBottomSheetShown)
    }
    
}


