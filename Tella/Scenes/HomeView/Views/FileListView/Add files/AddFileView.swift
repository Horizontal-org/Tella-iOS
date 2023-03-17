//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
// should move this to a separate file
enum ImportOption {
    case keepOriginal
    case deleteOriginal
}
struct AddFileView: View {
    @State private var importOption: ImportOption?

    @State private var fieldContent: String = ""
    @State private var isValid = false
    
//    @State var showingImagePicker : Bool = false
//    @State var showingImportDocumentPicker : Bool = false
//    @State var showingMicrophone : Bool = false
//    @State var showingCamera : Bool = false

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
                                 appModel: appModel)
        }
        .overlay(fileListViewModel.showingCamera ?
                 CameraView(sourceView: .addFile,
                            showingCameraView: $fileListViewModel.showingCamera,
                           mainAppModel: appModel,
                           rootFile: fileListViewModel.rootFile) : nil)
        
//        CameraViewModel(mainAppModel: appModel,
//                                         rootFile: fileListViewModel.rootFile)
        
        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(appModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone) : nil)
        
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
                fileListViewModel.add(folder: fieldContent)
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
        // localize values
        let importDeleteItems = ["keep original", "delete original"]
        let headerTitle = "Import and delete original file?"
        let content = "After importing the file into Tella, do you want to keep the original file on your device or delete it? If you delete it, the file imported into Tella will be the only copy left."
        
        let sheetContent = ConfirmationBottomSheet(options: importDeleteItems, headerTitle: headerTitle, content: content) { selectedItem in
            switch selectedItem {
            case "keep original":
                self.importOption = ImportOption.keepOriginal
            case "delete original":
                self.importOption = ImportOption.deleteOriginal
            default:
                break
            }
            switch itemType {
            case .photoLibrary:
                print(self.importOption)

                fileListViewModel.showingImagePicker = true
            default:
                print(self.importOption)
                fileListViewModel.showingImportDocumentPicker = true
            }
        }
        
        sheetManager.showBottomSheet(modalHeight: 400, content: {
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
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
