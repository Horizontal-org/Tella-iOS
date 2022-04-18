//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileView: View {
    
    @State private var showingAddPhotoVideoSheet = false
    @State private var showingCreateNewFolderSheet = false
    @State private var fieldContent: String = ""
    @State private var showingAddFileSheet = false
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel

    var body: some View {
        ZStack(alignment: .top) {
            
            AddFileYellowButton(action: {
                showingAddFileSheet = true
                fileListViewModel.selectingFiles = false
            })
            
            AddFilesBottomSheet(isPresented: $showingAddFileSheet,
                                showingAddPhotoVideoSheet: $showingAddPhotoVideoSheet,
                                showingCreateNewFolderSheet: $showingCreateNewFolderSheet)
            
            AddPhotoVideoBottomSheet(isPresented: $showingAddPhotoVideoSheet)
            
            TextFieldBottomSheetView(titleText: "Create new folder",
                                 validateButtonText: "CREATE",
                                 isPresented: $showingCreateNewFolderSheet,
                                 fieldContent: $fieldContent,
                                 fieldType: .text) {
                fileListViewModel.add(folder: fieldContent)
            }
        }
    }
}

struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
