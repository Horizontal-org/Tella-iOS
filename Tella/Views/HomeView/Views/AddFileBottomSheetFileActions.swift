//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

struct AddFileBottomSheetFileActions: View {
    
    @State private var showingAddPhotoVideoSheet = false
    @State private var showingCreateNewFolderSheet = false
    @State private var fieldContent: String = ""

    @Binding var isPresented: Bool
    @Binding var showingDocumentPicker: Bool
    @Binding var showingImagePicker: Bool

    @ObservedObject var appModel: MainAppModel
    var parent : VaultFile?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var items : [ListActionSheetItem] { return [
        ListActionSheetItem(imageName: "camera-icon",
                            content: "Take photo/video",
                            action: {
                                appModel.selectedTab = .camera
                                self.presentationMode.wrappedValue.dismiss()
                            }),
        ListActionSheetItem(imageName: "mic-icon",
                            content: "Record audio",
                            action: {
                                isPresented = false
                                appModel.changeTab(to: .mic)
                            }),
        ListActionSheetItem(imageName: "upload-icon",
                            content: "Import from device",
                            action: {
                                isPresented = false
                                showingAddPhotoVideoSheet = true
                            }),
        //        ListActionSheetItem(imageName: "import_delete-icon",
        //                            content: "Import and delete original file",
        //                            action: {
        //
        //                            }),
        
        ListActionSheetItem(imageName: "new_folder-icon",
                            content: "Create a new folder",
                            action: {
                                isPresented = false
                                showingCreateNewFolderSheet = true
                                showingAddPhotoVideoSheet = false
                            })
    ]}
    
    var body: some View {
        ZStack{
            DragView(modalHeight: CGFloat(items.count * 40 + 100),
                     isShown: $isPresented){
                ListActionSheet(items: items, headerTitle: "Manage files", isPresented: $isPresented)
            }
            
            AddPhotoVideoBottomSheet(isPresented: $showingAddPhotoVideoSheet,
                                     showingDocumentPicker: $showingDocumentPicker,
                                     showingImagePicker: $showingImagePicker,
                                     parent: parent)
            
            TextFieldBottomSheet(titleText: "Create new folder",
                                 validateButtonText: "CREATE",
                                       isPresented: $showingCreateNewFolderSheet,
                                 fieldContent: $fieldContent,
                                 fieldType: .text) {
                appModel.add(folder: fieldContent , to: parent)
            }
        }
    }
}
