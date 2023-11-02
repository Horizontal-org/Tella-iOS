//
//  PrimaryDocuments.swift
//  Tella
//
//  Created by Gustavo on 25/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct PrimaryDocuments: View {
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        UwaziFileSelector(addFiles: {
            UIApplication.shared.endEditing()
            showAddFileSheet()
        }, title: "Select PDF files")
            .environmentObject(prompt)
        FileItems(files: $entityViewModel.pdfDocuments)
    }
    
    func showAddFileSheet() {
            
            sheetManager.showBottomSheet( modalHeight: CGFloat(150), content: {
                ActionListBottomSheet(items: addFileToPdfItems,
                                      headerTitle: "Select files",
                                      action:  {item in
                    self.handleActions(item : item)
                })
            })
        }
    
    func showAddPhotoVideoSheet() {
        entityViewModel.showingImportDocumentPicker = true
    }
    
    var fileListView : some View {
        FileListView(appModel: entityViewModel.mainAppModel,
                        rootFile: entityViewModel.mainAppModel.vaultManager.root,
                        fileType: [.document],
                        title: LocalizableReport.selectFiles.localized,
                        fileListType: .selectFiles,
                        resultFile: $entityViewModel.resultFile)
        }
    
    private func handleActions(item: ListActionSheetItem) {
            
            guard let type = item.type as? ManageFileType else { return }
            
            switch type {
                
            case .fromDevice:
                showAddPhotoVideoSheet()
                
            case .tellaFile:
                sheetManager.hide()
                navigateTo(destination: fileListView)
                
            default:
                break
            }
        }
}

struct PrimaryDocuments_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryDocuments()
    }
}
