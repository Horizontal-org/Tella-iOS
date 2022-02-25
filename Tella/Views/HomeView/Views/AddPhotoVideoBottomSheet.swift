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
    @Binding var showingDocumentPicker: Bool
    @Binding var showingImagePicker: Bool

    var parent : VaultFile?
    
    
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
            DragView(modalHeight: CGFloat(items.count * 40 + 100),
                     isShown: $isPresented) {
                ListActionSheet(items: items,
                                headerTitle: "Import from device",
                                isPresented: $isPresented)
            }
        }
    }
}

struct AddPhotoVideoBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoVideoBottomSheet(isPresented: .constant(true),
                                 showingDocumentPicker: .constant(false),
                                 showingImagePicker: .constant(false),
                                 parent: nil)
    }
}
