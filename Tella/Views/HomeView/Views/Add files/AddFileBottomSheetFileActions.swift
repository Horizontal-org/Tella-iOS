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
    
    var body: some View {
        
        ZStack{
            
            AddFilesBottomSheet(isPresented: $isPresented,
                                showingAddPhotoVideoSheet: $showingAddPhotoVideoSheet,
                                showingCreateNewFolderSheet: $showingCreateNewFolderSheet)
            
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
