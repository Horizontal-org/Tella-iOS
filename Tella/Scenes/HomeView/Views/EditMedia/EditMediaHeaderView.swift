//
//  EditMediaHeaderView.swift
//  Tella
//
//  Created by RIMA on 19.11.24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI


struct EditMediaHeaderView: View {
    @ObservedObject var viewModel: EditMediaViewModel
    @State private var isBottomSheetShown : Bool = false
    var showRotate: (()->())?
    @Binding var isMiddleButtonEnabled : Bool
    
    var body: some View {
        
        NavigationHeaderView(title: viewModel.headerTitle,
                             backButtonType: .close,
                             backButtonAction: {self.closeView()},
                             middleButtonType:viewModel.file?.tellaFileType == .video ? .rotate : .none,
                             middleButtonAction: {showRotate?()},
                             isMiddleButtonEnabled: isMiddleButtonEnabled,
                             rightButtonType: viewModel.isDurationHasChanged() ? .editFile : .none,
                             rightButtonAction: { viewModel.trim() })
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
