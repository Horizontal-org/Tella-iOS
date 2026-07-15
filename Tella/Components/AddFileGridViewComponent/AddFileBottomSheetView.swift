//
//  AddFileBottomSheetView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct AddFileBottomSheetView<Content: View>: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    var content: () -> Content
    var moreAction: (() -> ())? = nil
    
    init(viewModel: AddFilesViewModel, content: @escaping () -> Content, moreAction: (() -> ())? = nil ) {
        self.viewModel = viewModel
        self.content = content
        self.moreAction = moreAction
    }
    var body: some View {
        Button {
            UIApplication.shared.endEditing()
            moreAction?()
            showAddFileSheet()
        } label: {
            content()
        }
    }
    
    func showAddFileSheet() {
        showBottomSheetView(content: ActionListBottomSheet(items: viewModel.bottomSheetItems,
                                                           headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                                           action: { item in
            self.handleActions(item: item)
        }))
    }
    
    private func handleActions(item: ListActionSheetItem) {
        guard let type = item.type as? ManageFileType else { return }
        
        switch type {
        case .camera:
            dismiss { viewModel.showingCamera = true }
            
        case .recorder:
            dismiss { viewModel.showingRecordView = true }
            
        case .fromDevice:
            showAddPhotoVideoSheet()
            
        case .tellaFile:
            dismiss { navigateTo(destination: fileListView) }
            
        default:
            dismiss()
        }
    }
    
    func showAddPhotoVideoSheet() {
        if viewModel.shouldShowDocumentsOnly {
            dismiss { viewModel.showingImportDocumentPicker = true }
        } else {
            dismiss {
                showBottomSheetView(content: ActionListBottomSheet(items: AddPhotoVideoItems,
                                                                   headerTitle: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized,
                                                                   action: { item in
                    self.handleAddPhotoVideoActions(item: item)
                }))
            }
        }
    }
    
    private func handleAddPhotoVideoActions(item: ListActionSheetItem) {
        guard let type = item.type as? AddPhotoVideoType else { return }
        
        switch type {
        case .photoLibrary:
            dismiss { viewModel.showingImagePicker = true }
        case .document:
            dismiss { viewModel.showingImportDocumentPicker = true }
        }
    }
    
    var fileListView: some View {
        FileListView(mainAppModel: viewModel.mainAppModel,
                     filterType: viewModel.shouldShowDocumentsOnly ? .pdf : .allWithoutDirectory,
                     title: LocalizableReport.selectFiles.localized,
                     fileListType: .selectFiles,
                     resultFile: $viewModel.resultFile)
    }
}
