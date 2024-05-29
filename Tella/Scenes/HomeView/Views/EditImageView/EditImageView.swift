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
    @Binding var isPresented : Bool
    @State var isBottomSheetShown : Bool = false

    var body: some View {
        ZStack {
            if viewModel.isDataLoaded {
                imageCropperView
            } else {
                ProgressView()
            }
            confirmExitBottomSheet
        }.onAppear {
            viewModel.loadFile()
        }
    }
    
    var imageCropperView : some View {
        ImageCropper(image: $viewModel.imageToEdit.wrappedValue) {
            isPresented = false
            viewModel.saveChanges()
            sheetManager.hide()
        } didCancelAction: {
            isBottomSheetShown = true
        }  
        .ignoresSafeArea()
    }

    var confirmExitBottomSheet: some View {
        DragView(modalHeight: 171, isShown: $isBottomSheetShown) {
            ConfirmBottomSheet(titleText: LocalizableVault.editFileConfirmExitTitle.localized,
                               msgText: LocalizableVault.editFileConfirmExitExpl.localized,
                               cancelText: LocalizableVault.editFileExitSheetAction.localized,
                               actionText:LocalizableVault.renameFileSaveSheetAction.localized, didConfirmAction: {
                self.viewModel.saveChanges()
                isPresented = false
            }, didCancelAction: {
                self.dismiss()
            })
        }
    }
}

