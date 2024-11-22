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
        HStack {
            Button(action: { self.closeView() }) {
                Image("file.edit.close")
            }
            Text(viewModel.headerTitle)
                .foregroundColor(.white)
            
            Spacer()
            
            if viewModel.isDurationHasChanged()  {
                Button(action: {
                    viewModel.trim()
                }) {
                    ResizableImage("edit.audio.cut")
                        .frame(width: 24, height: 24)
                }
            }
        }
        .frame(height: 30)
        .padding(16)
        
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

 
