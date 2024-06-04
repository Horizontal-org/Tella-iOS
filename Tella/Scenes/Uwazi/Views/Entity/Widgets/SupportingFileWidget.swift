//
//  SupportingFileWidget.swift
//  Tella
//
//  Created by Gustavo on 25/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SupportingFileWidget: View {
    @ObservedObject var prompt: UwaziFilesEntryPrompt
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        UwaziFileSelector(prompt: prompt, addFiles: {
            UIApplication.shared.endEditing()
            showAddFileSheet()
        }, title: LocalizableUwazi.uwaziEntitySelectFiles.localized)
            .environmentObject(prompt)
        if(prompt.value.count > 0) {
            FileDropdown(files: $prompt.value)
        }
    }
    
    func showAddFileSheet() {
            
            sheetManager.showBottomSheet( modalHeight: CGFloat(300), content: {
                ActionListBottomSheet(items: addFileToDraftItems,
                                      headerTitle: LocalizableUwazi.uwaziEntitySelectFiles.localized,
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
                     filterType: .audioPhotoVideo,
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

//struct SupportingFileWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SupportingFileWidget()
//    }
//}
