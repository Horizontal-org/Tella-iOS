//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFilesBottomSheet: View {
    
    @Binding var isPresented: Bool
    @Binding var showingAddPhotoVideoSheet : Bool
    @Binding var showingCreateNewFolderSheet : Bool
    
    @EnvironmentObject var appModel: MainAppModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var items : [ListActionSheetItem] { return [
        ListActionSheetItem(imageName: "camera-icon",
                            content: "Take photo/video",
                            action: {
                                isPresented = false
                                
                                appModel.selectedTab = .camera
                                self.presentationMode.wrappedValue.dismiss()
                            }),
        ListActionSheetItem(imageName: "mic-icon",
                            content: "Record audio",
                            action: {
                                isPresented = false
                                appModel.changeTab(to: .mic)
                                self.presentationMode.wrappedValue.dismiss()
                                
                            }),
        ListActionSheetItem(imageName: "upload-icon",
                            content: "Import from device",
                            action: {
                                isPresented = false
                                showingAddPhotoVideoSheet = true
                            }),
        
        ListActionSheetItem(imageName: "new_folder-icon",
                            content: "Create a new folder",
                            action: {
                                isPresented = false
                                showingCreateNewFolderSheet = true
                                showingAddPhotoVideoSheet = false
                            })
    ]
        
    }
    var body: some View {
        DragView(modalHeight: CGFloat(items.count * 50 + 90),
                 isShown: $isPresented){
            ActionListBottomSheet(items: items, headerTitle: "Manage files", isPresented: $isPresented)
        }
    }
}

struct AddFilesBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddFilesBottomSheet(isPresented: .constant(true),
                            showingAddPhotoVideoSheet: .constant(false),
                            showingCreateNewFolderSheet: .constant(false))
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())

    }
}
