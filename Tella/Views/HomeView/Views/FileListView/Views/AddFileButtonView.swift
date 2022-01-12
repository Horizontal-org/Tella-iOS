//
//  AddFileButtonView.swift
//  Tella
//
// 
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileButtonView: View {
    
    @ObservedObject var appModel: MainAppModel
    var rootFile: VaultFile?

    @State var showingDocumentPicker = false
    @State var showingImagePicker = false
    @State var showingAddFileSheet = false
    @Binding var selectingFiles : Bool

    var body: some View {
        ZStack {
            importFileActionSheet
            documentPickerView
            imagePickerView
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
                    appModel.add(files: [url], to: rootFile, type: .video)
                }
                if let image = image {
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
                    appModel.add(files: urls, to: rootFile, type: .document)
                }
            }
        )
    }
    
    var importFileActionSheet: some View {
        ZStack(alignment: .top) {
            AddFileYellowButton(action: {
                showingAddFileSheet = true
                selectingFiles = false
            })
            AddFileBottomSheetFileActions(isPresented: $showingAddFileSheet,
                                          showingDocumentPicker: $showingDocumentPicker,
                                          showingImagePicker: $showingImagePicker,
                                          appModel: appModel,
                                          parent: rootFile)
            
        }
    }

}
struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileButtonView(appModel: MainAppModel(), selectingFiles: .constant(false))
    }
}
