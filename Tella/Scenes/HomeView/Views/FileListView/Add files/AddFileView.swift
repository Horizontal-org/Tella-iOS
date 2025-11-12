//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct AddFileView: View {
    
    @State private var fieldContent: String = ""
    @State private var isValid = false

    @ObservedObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ZStack(alignment: .top) {
            
            AddFileYellowButton(action: {
                fileListViewModel.selectingFiles = false
                showAddFileSheet()
            })
            
            PhotoVideoPickerView(showingImagePicker: $fileListViewModel.showingImagePicker,
                                 showingImportDocumentPicker: $fileListViewModel.showingImportDocumentPicker,
                                 mainAppModel: fileListViewModel.mainAppModel,
                                 rootFile: $fileListViewModel.rootFile)
        }.ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(fileListViewModel.showingCamera ?
                 CameraView(sourceView: .addFile,
                            showingCameraView: $fileListViewModel.showingCamera,
                            mainAppModel: fileListViewModel.mainAppModel,
                            rootFile: fileListViewModel.rootFile) : nil)

        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(mainAppModel: fileListViewModel.mainAppModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone) : nil)
        
    }
    
    func showAddFileSheet() {
        sheetManager.showBottomSheet {
            ActionListBottomSheet(items: fileListViewModel.manageFilesItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                self.handleActions(item : item)
            })
        }
    }
    
    func showCreateNewFolderSheet() {
        sheetManager.showBottomSheet {
            TextFieldBottomSheetView(titleText: LocalizableVault.manageFilesCreateNewFolderSheetSelect.localized,
                                     validateButtonText: LocalizableVault.createNewFolderCreateSheetAction.localized,
                                     cancelButtonText: LocalizableVault.createNewFolderCancelSheetAction.localized,
                                     fieldContent: $fieldContent) {
                fileListViewModel.addFolder(name: fieldContent)
            }
        }
    }
    
    func showAddPhotoVideoSheet() {
        sheetManager.showBottomSheet {
            ActionListBottomSheet(items: AddPhotoVideoItems,
                                  headerTitle: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized, action: {item in
                self.handleAddPhotoVideoActions(item : item)
            })
        }
    }
    
    func showImportDeleteSheet(itemType: AddPhotoVideoType) {
        let importDeleteItems = MainAppModel.ImportOption.allCases
        let headerTitle = LocalizableVault.importDeleteTitle.localized
        let content = LocalizableVault.importDeleteContent.localized
        let subContent = LocalizableVault.importDeleteSubcontent.localized
        
        let sheetContent = ConfirmationBottomSheet(options: importDeleteItems, headerTitle: headerTitle, content: content, subContent: subContent) {
            selectedItem in
            fileListViewModel.mainAppModel.importOption = selectedItem
            switch itemType {
            case .photoLibrary:
                fileListViewModel.showingImagePicker = true
            default:
                fileListViewModel.showingImportDocumentPicker = true
            }
            sheetManager.hide()
        }
        sheetManager.showBottomSheet {
            sheetContent
        }
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
        AddFileView(fileListViewModel: FileListViewModel.stub())
            .environmentObject(MainAppModel.stub())
    }
}
