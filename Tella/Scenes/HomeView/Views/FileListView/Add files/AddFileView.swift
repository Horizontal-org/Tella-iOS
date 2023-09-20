//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileView: View {

    @State private var fieldContent: String = ""
    @State private var isValid = false

    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ZStack(alignment: .top) {
            
            AddFileYellowButton(action: {
                fileListViewModel.selectingFiles = false
                showAddFileSheet()
            })
            
            PhotoVideoPickerView(showingImagePicker: $fileListViewModel.showingImagePicker,
                                 showingImportDocumentPicker: $fileListViewModel.showingImportDocumentPicker,
                                 appModel: appModel,
                                 rootFile: $fileListViewModel.rootFile, 
                                 shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles)
        }
        .overlay(fileListViewModel.showingCamera ?
                 CameraView(sourceView: .addFile,
                            showingCameraView: $fileListViewModel.showingCamera,
                            mainAppModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles ) : nil)

        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(appModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone, 
                            shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles) : nil)
        
    }
    
    func showAddFileSheet() {
        sheetManager.showBottomSheet( modalHeight: CGFloat(manageFilesItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: manageFilesItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                self.handleActions(item : item)
            })
        })
    }
    
    func showCreateNewFolderSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            TextFieldBottomSheetView(titleText: LocalizableVault.manageFilesCreateNewFolderSheetSelect.localized,
                                     validateButtonText: LocalizableVault.createNewFolderCreateSheetAction.localized,
                                     cancelButtonText: LocalizableVault.createNewFolderCancelSheetAction.localized,
                                     fieldContent: $fieldContent) {
                fileListViewModel.addFolder(name: fieldContent)
            }
        })
    }
    
    func showAddPhotoVideoSheet() {
        sheetManager.showBottomSheet( modalHeight:  CGFloat(AddPhotoVideoItems.count * 40 + 100), content: {
            ActionListBottomSheet(items: AddPhotoVideoItems,
                                  headerTitle: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized, action: {item in
                self.handleAddPhotoVideoActions(item : item)
            })
        })
    }
    
    func showImportDeleteSheet(itemType: AddPhotoVideoType) {
        let importDeleteItems = MainAppModel.ImportOption.allCases
        let headerTitle = LocalizableVault.importDeleteTitle.localized
        let content = LocalizableVault.importDeleteContent.localized
        let subContent = LocalizableVault.importDeleteSubcontent.localized
        
        let sheetContent = ConfirmationBottomSheet(options: importDeleteItems, headerTitle: headerTitle, content: content, subContent: subContent) {
            selectedItem in
            appModel.importOption = selectedItem
            switch itemType {
            case .photoLibrary:
                fileListViewModel.showingImagePicker = true
            default:
                fileListViewModel.showingImportDocumentPicker = true
            }
            sheetManager.hide()
        }
        sheetManager.showBottomSheet(modalHeight: 300, content: {
            sheetContent
        })
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? ManageFileType else { return }
        
        switch type {
            
        case .camera:
            sheetManager.hide()
            fileListViewModel.showingCamera = true
            
        case .recorder:
            sheetManager.hide()
            fileListViewModel.showingMicrophone = true
            
        case .fromDevice:
            showAddPhotoVideoSheet()
            
        default:
            showCreateNewFolderSheet()
        }
    }
    
    
    private func handleAddPhotoVideoActions(item: ListActionSheetItem) {
        guard let type = item.type as? AddPhotoVideoType else { return  }
        
        
        showImportDeleteSheet(itemType: type)
    }
}

struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView()
            .environmentObject(MainAppModel.stub())
            .environmentObject(FileListViewModel.stub())
    }
}
