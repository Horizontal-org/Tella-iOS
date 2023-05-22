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
         resultFile : Binding<[VaultFile]?>? = nil) {
        
        _viewModel = StateObject(wrappedValue: PhotoVideoViewModel(mainAppModel: appModel,
                                                                   folderPathArray: [],
                                                                   resultFile: resultFile))
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
                ImagePickerView { image, url, pathExtension, imageURL, actualURL in
                    
                    self.showingImagePicker.wrappedValue = false
                    
                    if let url = url {
                        showProgressView()
                        if viewModel.mainAppModel.settings.preserveMetadata {
                            viewModel.add(files: [url], type: .video)
                        } else {
                            viewModel.addVideoWithoutExif(files: [url], type: .video)
                        }

                    }
                    if let image = image {
                         showProgressView()
                        if viewModel.mainAppModel.settings.preserveMetadata {
                            viewModel.addWithExif(image: image, type: .image, pathExtension: pathExtension, originalUrl: imageURL, acturalURL: actualURL)
                        } else {
                            viewModel.add(image: image, type: .image, pathExtension: pathExtension, originalUrl: imageURL, acturalURL: actualURL)
                        }
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
                        showProgressView()
                        viewModel.add(files: urls, type: .document)
                    }
                }
            )
    }
    
    func showProgressView() {
        sheetManager.showBottomSheet(modalHeight: 190,
                                     shouldHideOnTap: false,
                                     content: {
            ImportFilesProgressView(importFilesProgressProtocol: ImportFilesProgress())
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
