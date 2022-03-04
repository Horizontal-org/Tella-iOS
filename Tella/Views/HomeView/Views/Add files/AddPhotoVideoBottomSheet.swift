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
    var rootFile : VaultFile?
    
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var showingProgressView : Bool = false
    
    @EnvironmentObject private var appModel: MainAppModel
    
    var items : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "photo-library",
                            content: "Photo Library",
                            action: {
                                showingImagePicker = true
                            }),
        
        ListActionSheetItem(imageName: "document",
                            content: "Document",
                            action: {
                                showingDocumentPicker = true
                            }),
    ]}
    
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
        DragView(modalHeight: CGFloat(items.count * 40 + 100),
                 isShown: $isPresented) {
            ActionListBottomSheet(items: items,
                                  headerTitle: "Import from device",
                                  isPresented: $isPresented)
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
                    appModel.add(files: urls ?? [], to: rootFile, type: .document)
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
                    appModel.add(files: [url], to: rootFile, type: .video)
                }
                if let image = image {
                    showingProgressView = true
                    appModel.add(image: image, to: rootFile, type: .image, pathExtension: pathExtension ?? "png")
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
                    appModel.add(files: urls, to: rootFile, type: .document)
                }
            }
        )
    }
    
}

struct AddPhotoVideoBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoVideoBottomSheet(isPresented: .constant(true),
                                 rootFile: nil)
    }
}
