//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFilesBottomSheet: View {
    
    @Binding var isPresented: Bool
    @Binding var showingAddPhotoVideoSheet : Bool
    @Binding var showingCreateNewFolderSheet : Bool
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            DragView(modalHeight: CGFloat(manageFilesItems.count * 50 + 90),
                     isShown: $isPresented){
                ActionListBottomSheet(items: manageFilesItems, headerTitle: "Manage files", isPresented: $isPresented, action:  {item in
                    self.handleActions(item : item)
                    
                    
                })
            }
        }
        .overlay(fileListViewModel.showingCamera ?
                 CameraView(sourceView: .addFile,
                            showingCameraView: $fileListViewModel.showingCamera,
                            cameraViewModel: CameraViewModel(mainAppModel: appModel,
                                                             rootFile: fileListViewModel.rootFile)) : nil)
        
        .overlay(fileListViewModel.showingMicrophone ?
                 RecordView(appModel: appModel,
                            rootFile: fileListViewModel.rootFile,
                            sourceView: .addFile,
                            showingRecoredrView: $fileListViewModel.showingMicrophone) : nil)
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? ManageFileType else { return }
        
        switch type {
        case .camera:
            isPresented = false
            fileListViewModel.showingCamera = true
            
        case .recorder:
            isPresented = false
            fileListViewModel.showingMicrophone = true
            
        case .fromDevice:
            isPresented = false
            showingAddPhotoVideoSheet = true
            
        default:
            isPresented = false
            showingCreateNewFolderSheet = true
            showingAddPhotoVideoSheet = false
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
