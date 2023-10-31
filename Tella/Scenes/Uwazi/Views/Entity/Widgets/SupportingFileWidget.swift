//
//  SupportingFileWidget.swift
//  Tella
//
//  Created by Gustavo on 25/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SupportingFileWidget: View {
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        UwaziFileSelector(addFiles: {
            UIApplication.shared.endEditing()
            showAddFileSheet()
        }, title: "Select Files")
            .environmentObject(prompt)
        if(entityViewModel.files.count > 0) {
            FileDropdown(files: $entityViewModel.files)
        }
    }
    
    func showAddFileSheet() {
            
            sheetManager.showBottomSheet( modalHeight: CGFloat(300), content: {
                ActionListBottomSheet(items: entityViewModel.addFileToDraftItems,
                                      headerTitle: "Select files",
                                      action:  {item in
                    self.handleActions(item : item)
                })
            })
        }
    
    func showAddPhotoVideoSheet() {
        
            entityViewModel.showingImagePicker = true
        }
    
    var fileListView : some View {
        FileListView(appModel: entityViewModel.mainAppModel,
                         rootFile: entityViewModel.mainAppModel.vaultManager.root,
                         fileType: [.audio,.image,.video],
                         title: LocalizableReport.selectFiles.localized,
                         fileListType: .selectFiles,
                         resultFile: $entityViewModel.resultFile)
        }
    
    private func handleActions(item: ListActionSheetItem) {
            
            guard let type = item.type as? ManageFileType else { return }
            
            switch type {
                
            case .camera:
                sheetManager.hide()
                entityViewModel.showingCamera = true
                
            case .recorder:
                sheetManager.hide()
                entityViewModel.showingRecordView = true
                
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

struct SupportingFileWidget_Previews: PreviewProvider {
    static var previews: some View {
        SupportingFileWidget()
    }
}
