//
//  AddPhotoVideoBottomSheet.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PhotoVideoPickerView: View {
    
    @EnvironmentObject private var appModel: MainAppModel
    @EnvironmentObject private var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        documentPickerView
        imagePickerView
    }
    
    @ViewBuilder
    var documentPickerView: some View {
        if #available(iOS 14.0, *) {
            addFileDocumentImporter
        } else {
            HStack{}
                .sheet(isPresented:  $fileListViewModel.showingImportDocumentPicker, content: {
                    DocumentPickerView(documentPickerType: .forImport) { urls in
                        showProgressView()
                        fileListViewModel.add(files: urls ?? [], type: .document)
                    }
                })
        }
    }
    
    var imagePickerView: some View {
        HStack{}
            .sheet(isPresented: $fileListViewModel.showingImagePicker, content: {
                ImagePickerView { image, url, pathExtension in
                    
                    fileListViewModel.showingImagePicker = false
                    
                    if let url = url {
                        showProgressView()
                        fileListViewModel.add(files: [url], type: .video)
                    }
                    if let image = image {
                        showProgressView()
                        fileListViewModel.add(image: image, type: .image, pathExtension: pathExtension)
                    }
                }
            })
    }
    
    @available(iOS 14.0, *)
    var addFileDocumentImporter: some View {
        HStack{}
            .fileImporter(
                isPresented: $fileListViewModel.showingImportDocumentPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    if let urls = try? result.get() {
                        showProgressView()
                        fileListViewModel.add(files: urls, type: .document)
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

struct AddPhotoVideoBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        PhotoVideoPickerView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
        
    }
}
