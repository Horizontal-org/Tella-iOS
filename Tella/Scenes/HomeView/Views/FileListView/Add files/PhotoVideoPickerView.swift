//
//  AddPhotoVideoBottomSheet.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine
import Photos

struct PhotoVideoPickerView: View {
    
    @StateObject var viewModel : PhotoVideoViewModel
    var showingImagePicker : Binding<Bool>
    var showingImportDocumentPicker : Binding<Bool>
    @State private var showingImagePickerSheet : Bool = false
    private let delayTimeInSecond = 0.5
    @State var authorizationStatus : PHAuthorizationStatus = .notDetermined
    
    @EnvironmentObject var sheetManager: SheetManager
    
    init(showingImagePicker: Binding<Bool>,
         showingImportDocumentPicker: Binding<Bool>,
         appModel: MainAppModel,
         resultFile : Binding<[VaultFileDB]?>? = nil,
         rootFile:Binding<VaultFileDB?>? = nil) {
        
        _viewModel = StateObject(wrappedValue: PhotoVideoViewModel(mainAppModel: appModel,
                                                                   folderPathArray: [],
                                                                   resultFile: resultFile,
                                                                   rootFile: rootFile))
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
                ImagePickerSheet { assets in
                    self.showingImagePickerSheet = false
                    
                    if assets != nil  {
                        if assets?.count != 0 && viewModel.shouldShowProgressView {
                            showProgressView()
                        }
                        viewModel.handleAddingFile(assets)
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
                    showingImagePickerSheet = true
                case .limited:
                    showLimitedAccessView()
                default:
                    showAccessDeniedUI()
                }
            }
        }
    }
    
    private func showAccessDeniedUI()  {
        
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
    
    func showLimitedAccessView() {
        
        let view = LimitedAccessPhotoView { assets in
            if assets.count != 0 && viewModel.shouldShowProgressView {
                showProgressView()
            }
            viewModel.handleAddingFile(assets)
        }
        
        self.present(style: .fullScreen,
                     transitionStyle: .crossDissolve,
                     builder: {view})
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
