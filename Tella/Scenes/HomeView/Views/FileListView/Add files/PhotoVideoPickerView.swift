//
//  AddPhotoVideoBottomSheet.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine
import Photos

struct PhotoVideoPickerView: View {
    
    @StateObject var viewModel : PhotoVideoViewModel
    var showingImagePicker : Binding<Bool>
    var showingImportDocumentPicker : Binding<Bool>
    @State private var showingImagePickerSheet : Bool = false
    @State private var showingPermissionAlert : Bool = false
    @State private var showingLimitedPhotoAlert : Bool = false
    @State private var showingPicker = false
    private let delayTimeInSecond = 0.5
    @State var authorizationStatus : PHAuthorizationStatus = .notDetermined
    
    @EnvironmentObject private var appModel: MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    
    init(showingImagePicker: Binding<Bool>,
         showingImportDocumentPicker: Binding<Bool>,
         appModel: MainAppModel,
         resultFile : Binding<[VaultFileDB]?>? = nil,
         rootFile:Binding<VaultFileDB?>? = nil,
         shouldReloadVaultFiles: Binding<Bool>) {
        
        _viewModel = StateObject(wrappedValue: PhotoVideoViewModel(mainAppModel: appModel,
                                                                   folderPathArray: [],
                                                                   resultFile: resultFile,
                                                                   rootFile: rootFile,
                                                                   shouldReloadVaultFiles: shouldReloadVaultFiles))
        self.showingImagePicker = showingImagePicker
        self.showingImportDocumentPicker = showingImportDocumentPicker
    }
    
    var body: some View {
        ZStack {
            addFileDocumentImporter
            imagePickerView
            
        }.onReceive(Just(showingImagePicker.wrappedValue)) { showingImagePicker in
            checkPhotoLibraryAuthorization(showingImagePicker:showingImagePicker)
        }
    }
    
    var imagePickerView: some View {
        
        HStack{}
            .sheet(isPresented: $showingImagePickerSheet, content: {
                ImagePickerSheet { phPickerCompletion in
                    self.showingImagePickerSheet = false
                    if phPickerCompletion != nil  {
                        if phPickerCompletion?.assets.count != 0 && viewModel.shouldShowProgressView {
                            showProgressView()
                        }
                        viewModel.handleAddingFile(phPickerCompletion)
                    }
                }
            })
    }
    
    func checkPhotoLibraryAuthorization(showingImagePicker:Bool) {
        if showingImagePicker == true {
            self.showingImagePicker.wrappedValue = false
            
            Task {
                let authorizationStatus = await PHPhotoLibrary.checkPhotoLibraryAuthorization()
                self.authorizationStatus =   authorizationStatus
                
                switch authorizationStatus {
                case .authorized:
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTimeInSecond) {
                        showingImagePickerSheet = true
                    }
                case .limited:
                    showingPermissionAlert = true
                default:
                    showDeniedPermissionSheetView()
                }
            }
        }
    }
    
    private func showDeniedPermissionSheetView()  {
        
        let content = ConfirmBottomSheet(titleText: LocalizableVault.deniedPhotoLibraryPermissionTitle.localized,
                                         msgText: LocalizableVault.deniedPhotoLibraryPermissionExpl.localized,
                                         cancelText: LocalizableVault.deniedPhotosPermissionCancel.localized.uppercased(),
                                         actionText:LocalizableVault.deniedPhotosPermissionSettings.localized.uppercased(),
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            UIApplication.shared.openSettings()
        }, didCancelAction: {
            self.dismiss()
        })
        
        self.showBottomSheetView(content: content, modalHeight: 255)
    }
    
    private func getLimitedPhotoLibraryAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableVault.limitedPhotoLibraryPermissionExpl.localized),
              primaryButton: .default(Text(LocalizableVault.limitedPhotoLibraryPermissionCancel.localized), action: {
            
        }), secondaryButton: .default(Text(LocalizableVault.limitedPhotoLibraryPermissionSettings.localized), action: {
            UIApplication.shared.openSettings()
        }))
    }
    
    var addFileDocumentImporter: some View {
        HStack{}
            .fileImporter(
                isPresented:  showingImportDocumentPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    if let urls = try? result.get() {
                        if urls.count != 0 && viewModel.shouldShowProgressView{
                            showProgressView()
                        }
                        viewModel.addDocuments(urls: urls)
                    }
                }
            )
    }
    
    func showProgressView() {
        viewModel.progressFile = ProgressFile()
        sheetManager.showBottomSheet(modalHeight: 190,
                                     shouldHideOnTap: false,
                                     content: {
            ImportFilesProgressView(progress: viewModel.progressFile,
                                    importFilesProgressProtocol: ImportFilesProgress())
            
        })
    }
}

//struct AddPhotoVideoBottomSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoVideoPickerView()
//            .environmentObject(MainAppModel())
//            .environmentObject(FileListViewModel.stub())
//
//    }
//}
