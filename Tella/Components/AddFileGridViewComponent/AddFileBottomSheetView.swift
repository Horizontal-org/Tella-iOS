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
    @EnvironmentObject var sheetManager: SheetManager
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
        sheetManager.showBottomSheet(modalHeight: CGFloat(viewModel.bottomSheetItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: viewModel.bottomSheetItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action: { item in
                self.handleActions(item: item)
            })
        })
    }
    
    private func handleActions(item: ListActionSheetItem) {
        guard let type = item.type as? ManageFileType else { return }
        
        switch type {
        case .camera:
            viewModel.showingCamera = true
            
        case .recorder:
            viewModel.showingRecordView = true
            
        case .fromDevice:
            showAddPhotoVideoSheet()
            
        case .tellaFile:
            navigateTo(destination: fileListView)
            
        default:
            break
        }
        sheetManager.hide()
    }
    
    func showAddPhotoVideoSheet() {
        viewModel.showingImagePicker = true
    }
    
    var fileListView: some View {
        FileListView(appModel: viewModel.mainAppModel,
                     filterType: viewModel.shouldShowDocumentsOnly ? .documents : .audioPhotoVideo,
                     title: LocalizableReport.selectFiles.localized,
                     fileListType: .selectFiles,
                     resultFile: $viewModel.resultFile)
    }
}
