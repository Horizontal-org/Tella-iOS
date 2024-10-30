//
//  EditImageView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Mantis

struct EditImageView: View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @StateObject var viewModel: EditImageViewModel
    @State var isBottomSheetShown : Bool = false

    var body: some View {
        ZStack {
            if viewModel.isDataLoaded {
                imageCropperView
            } else {
                ProgressView()
            }
            EditFileCancelBottomSheet(isShown: $isBottomSheetShown, saveAction: { handleSaveAction() })
        }.onAppear {
            viewModel.loadFile()
        }
    }
    
    var imageCropperView : some View {
        ImageCropper(image: $viewModel.imageToEdit.wrappedValue) {
            handleSaveAction()
        } didCancelAction: {
            isBottomSheetShown = true
        }  
        .ignoresSafeArea()
    }
    private func handleSaveAction() {
        self.viewModel.saveChanges()
        self.dismiss()
        Toast.displayToast(message: LocalizableVault.editFileSavedToast.localized)
    }
}

