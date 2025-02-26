//
//  AddFileBottomSheetView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddFileBottomSheetView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var imageIcon = "add.file.icon"
    
    var body: some View {
        Button {
            UIApplication.shared.endEditing()
            showAddFileSheet()
        } label: {
            Image(imageIcon)
        }
    }
    
    func showAddFileSheet() {
        sheetManager.showBottomSheet(modalHeight: CGFloat(viewModel.addFileBottomSheetItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: viewModel.addFileBottomSheetItems,
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
                     filterType: .audioPhotoVideo,
                     title: LocalizableReport.selectFiles.localized,
                     fileListType: .selectFiles,
                     resultFile: $viewModel.resultFile)
    }
}
