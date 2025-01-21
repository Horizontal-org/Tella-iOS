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
                             trailingButton: viewModel.isDurationHasChanged() ? .editFile : .none,
                             trailingButtonAction: { viewModel.trim() })
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
        let content = EditFileCancelBottomSheet( saveAction:  { viewModel.trim() }, cancelAction: {self.dismiss()} )
        self.showBottomSheetView(content: content, modalHeight: 171, isShown: $isBottomSheetShown)
    }
}
