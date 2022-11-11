//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFilesToDraftView: View {
    
    @State private var fieldContent: String = ""
    @State private var isValid = false

    @EnvironmentObject var appModel: MainAppModel
    @StateObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    
    init(appModel: MainAppModel, rootFile: VaultFile , fileType: [FileType]? , title : String = "", fileListType : FileListType = .fileList) {
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel,fileType:fileType, rootFile: rootFile, folderPathArray: [], fileListType :  fileListType))

    }

    
    var body: some View {
        
        ZStack {
            attachedFile
            
            PhotoVideoPickerView()
        }
        .environmentObject(fileListViewModel)
        
//        .overlay(fileListViewModel.showingCamera ?
//                 CameraView(sourceView: .addFile,
//                            showingCameraView: $fileListViewModel.showingCamera,
//                            cameraViewModel: CameraViewModel(mainAppModel: appModel,
//                                                             rootFile: fileListViewModel.rootFile), customCameraRepresentable: <#CustomCameraRepresentable#> ) : nil)
        
        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(appModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone) : nil)
        
    }
    
    var attachedFile : some View {
        
        VStack {
            Text("Attach files here")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Button {
                showAddFileSheet()
            } label: {
                Image("reports.add")
            }
        }
    }
    
    
    
    func showAddFileSheet() {
        sheetManager.showBottomSheet( modalHeight: CGFloat(AddFileToDraftItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: AddFileToDraftItems,
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

struct AddFilesToDraftView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}




var AddFileToDraftItems : [ListActionSheetItem] { return [
    
    ListActionSheetItem(imageName: "report.camera-filled",
                        content: "Take photo or video with camera",
                        type: ManageFileType.camera),
    ListActionSheetItem(imageName: "report.mic-filled",
                        content: "Record audio",
                        type: ManageFileType.recorder),
    ListActionSheetItem(imageName: "report.gallery",
                        content: "Select from Tella files",
                        type: ManageFileType.tellaFile),
    ListActionSheetItem(imageName: "report.phone",
                        content: "Select from your device",
                        type: ManageFileType.fromDevice)
]
}



//            DragView(modalHeight: CGFloat(AddFileToDraftItems.count * 50 + 90),
//                     shouldHideOnTap: true,
//                     isShown: $shouldShowSelectFiles) {
//                ActionListBottomSheet(items: AddFileToDraftItems,
//                                      headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
//                                      action:  {item in
//                    self.handleActions(item : item)
//                })
//
//            }
