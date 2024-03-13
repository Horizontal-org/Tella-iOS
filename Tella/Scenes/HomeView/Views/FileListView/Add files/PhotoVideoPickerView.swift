//
//  AddPhotoVideoBottomSheet.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PhotoVideoPickerView: View {
    
    @StateObject var viewModel : PhotoVideoViewModel
    var showingImagePicker : Binding<Bool>
    var showingImportDocumentPicker : Binding<Bool>
    
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
        addFileDocumentImporter
        imagePickerView
    }

    var imagePickerView: some View {
        HStack{}
            .sheet(isPresented:  showingImagePicker, content: {
                ImagePickerSheet { imagePickerCompletion in
                    self.showingImagePicker.wrappedValue = false
                    if imagePickerCompletion != nil  {
                        if viewModel.shouldShowProgressView {
                            showProgressView()
                        }
                        viewModel.handleAddingFile(imagePickerCompletion)
                    }
                }
            })
    }
    
    
    var addFileDocumentImporter: some View {
        HStack{}
            .fileImporter(
                isPresented:  showingImportDocumentPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    if let urls = try? result.get() {
                        if viewModel.shouldShowProgressView {
                            showProgressView()
                        }
                        viewModel.addDocuments(urls: urls)
                    }
                }
            )
    }
    
    func showProgressView() {
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
