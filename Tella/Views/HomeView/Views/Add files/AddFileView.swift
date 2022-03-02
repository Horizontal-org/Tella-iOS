//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileView: View {
    
    @State private var showingAddPhotoVideoSheet = false
    @State private var showingCreateNewFolderSheet = false
    @State private var fieldContent: String = ""
    @State private var showingAddFileSheet = false
    
    @ObservedObject var appModel: MainAppModel
    var rootFile: VaultFile?
    @Binding var selectingFiles : Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            
            AddFileYellowButton(action: {
                showingAddFileSheet = true
                selectingFiles = false
            })
            
            AddFilesBottomSheet(isPresented: $showingAddFileSheet,
                                showingAddPhotoVideoSheet: $showingAddPhotoVideoSheet,
                                showingCreateNewFolderSheet: $showingCreateNewFolderSheet)
            
            AddPhotoVideoBottomSheet(isPresented: $showingAddPhotoVideoSheet,
                                     rootFile: rootFile)
            
            TextFieldBottomSheet(titleText: "Create new folder",
                                 validateButtonText: "CREATE",
                                 isPresented: $showingCreateNewFolderSheet,
                                 fieldContent: $fieldContent,
                                 fieldType: .text) {
                appModel.add(folder: fieldContent , to: rootFile)
            }
        }
    }
}

struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView(appModel: MainAppModel(), selectingFiles: .constant(false))
    }
}
