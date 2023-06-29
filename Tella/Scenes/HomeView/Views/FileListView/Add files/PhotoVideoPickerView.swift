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
                ImagePickerSheet { imagePickerCompletion in
                    
                    self.showingImagePicker.wrappedValue = false
                    let isPreserveMetadataOn = viewModel.mainAppModel.settings.preserveMetadata
                    if let completion = imagePickerCompletion {
                        showProgressView()
                        switch completion.type {
                        case .video:
                            handleAddingVideo(completion, isPreserveMetadataOn)
                        case .image:
                            handleAddingImage(completion, isPreserveMetadataOn)

                        }
                    }
                }
            })
    }
    // TODO: Move to ViewModel
    fileprivate func handleAddingVideo(_ completion: ImagePickerCompletion, _ isPreserveMetadataOn: Bool) {
        if let url = completion.videoURL {
            if isPreserveMetadataOn{
                viewModel.addVideoWithExif(files: [url], type: .video)
            } else {
                viewModel.addVideoWithoutExif(files: [url], type: .video)
            }
        }
    }

    fileprivate func handleAddingImage(_ completion: ImagePickerCompletion, _ isPreserveMetadataOn: Bool) {
        if let image = completion.image {
            if isPreserveMetadataOn {
                viewModel.addImageWithExif(image: image, type: .image, pathExtension: completion.pathExtension, originalUrl: completion.referenceURL, actualURL: completion.imageURL)
            } else {
                viewModel.addImageWithoutExif(image: image, type: .image, pathExtension: completion.pathExtension, originalUrl: completion.referenceURL)
            }
        }
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
                        viewModel.addVideoWithExif(files: urls, type: .document)
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
