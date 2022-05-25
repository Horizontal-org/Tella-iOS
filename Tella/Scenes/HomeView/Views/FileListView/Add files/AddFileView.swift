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
            
            PhotoVideoPickerView()
        }
        .overlay(fileListViewModel.showingCamera ?
                 CameraView(sourceView: .addFile,
                            showingCameraView: $fileListViewModel.showingCamera,
                            cameraViewModel: CameraViewModel(mainAppModel: appModel,
                                                             rootFile: fileListViewModel.rootFile)) : nil)
        
        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(appModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone) : nil)
        
    }
    
    func showAddFileSheet() {
        sheetManager.showBottomSheet( modalHeight: CGFloat(manageFilesItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: manageFilesItems,
                                  headerTitle: Localizable.Vault.manageFilesSheetTitle,
                                  action:  {item in
                self.handleActions(item : item)
            })
        })
    }
    
    func showCreateNewFolderSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            TextFieldBottomSheetView(titleText: Localizable.Vault.manageFilesCreateNewFolderSheetSelect,
                                     validateButtonText: Localizable.Vault.createNewFolderCreateSheetAction,
                                     cancelButtonText: Localizable.Vault.createNewFolderCancelSheetAction,
                                     fieldContent: $fieldContent,
                                     fieldType: .text) {
                fileListViewModel.add(folder: fieldContent)
            }
        })
    }
    
    func showAddPhotoVideoSheet() {
        sheetManager.showBottomSheet( modalHeight:  CGFloat(AddPhotoVideoItems.count * 40 + 100), content: {
            ActionListBottomSheet(items: AddPhotoVideoItems,
                                  headerTitle: Localizable.Vault.manageFilesImportFromDeviceSheetSelect, action: {item in
                self.handleAddPhotoVideoActions(item : item)
            })
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
        
        switch type {
        case .photoLibrary:
            fileListViewModel.showingImagePicker = true
        default:
            fileListViewModel.showingImportDocumentPicker = true
        }
    }
}

struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
