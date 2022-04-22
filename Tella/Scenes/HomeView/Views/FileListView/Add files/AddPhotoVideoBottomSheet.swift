//
//  AddPhotoVideoBottomSheet.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddPhotoVideoBottomSheet: View {
    
    @Binding var isPresented: Bool
    
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var showingProgressView : Bool = false
    
    @EnvironmentObject private var appModel: MainAppModel
    @EnvironmentObject private var fileListViewModel: FileListViewModel
    
    var body: some View {
        
        ZStack{
            
            actionListBottomSheet
            
            documentPickerView
            
            imagePickerView
            
            ImportFilesProgressView(showingProgressView: $showingProgressView,
                                    importFilesProgressProtocol: ImportFilesProgress())
        }
    }
    
    var actionListBottomSheet: some View {
        DragView(modalHeight: CGFloat(AddPhotoVideoItems.count * 40 + 100),
                 isShown: $isPresented) {
            ActionListBottomSheet(items: AddPhotoVideoItems,
                                  headerTitle: Localizable.Home.importFromDevice,
                                  isPresented: $isPresented, action: {item in
                self.handleActions(item : item)
            })
        }
    }
    
    @ViewBuilder
    var documentPickerView: some View {
        if #available(iOS 14.0, *) {
            addFileDocumentImporter
        } else {
            HStack{}
            .sheet(isPresented: $showingDocumentPicker, content: {
                DocumentPickerView(documentPickerType: .forImport) { urls in
                    showingProgressView = true
                    fileListViewModel.add(files: urls ?? [], type: .document)
                }
            })
        }
    }
    
    var imagePickerView: some View {
        HStack{}
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePickerView { image, url, pathExtension in
                
                showingImagePicker = false
                
                if let url = url {
                    showingProgressView = true
                    fileListViewModel.add(files: [url], type: .video)
                }
                if let image = image {
                    showingProgressView = true
                    fileListViewModel.add(image: image, type: .image, pathExtension: pathExtension)
                }
            }
        })
    }
    
    @available(iOS 14.0, *)
    var addFileDocumentImporter: some View {
        HStack{}
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: true,
            onCompletion: { result in
                if let urls = try? result.get() {
                    showingProgressView = true
                    fileListViewModel.add(files: urls, type: .document)
                }
            }
        )
    }
    
    private func handleActions(item: ListActionSheetItem) {
        guard let type = item.type as? AddPhotoVideoType else { return  }
        
        switch type {
        case .photoLibrary:
            showingImagePicker = true
        default:
            showingDocumentPicker = true
        }
    }
}

struct AddPhotoVideoBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoVideoBottomSheet(isPresented: .constant(true))
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
        
    }
}
