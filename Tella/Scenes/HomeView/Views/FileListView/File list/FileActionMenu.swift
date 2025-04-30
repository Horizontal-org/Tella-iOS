//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FileActionMenu: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @ObservedObject var fileListViewModel: FileListViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isPresented = true
    
    var body: some View {
        if fileListViewModel.showingMoveFileView {
            moveFilesView
        }
    }
    
    var moveFilesView : some View {
        MoveFilesView(title: fileListViewModel.fileActionsTitle, fileListViewModel: fileListViewModel)
    }
}

struct FileActionMenu_Previews: PreviewProvider {
    static var previews: some View {
        FileActionMenu(fileListViewModel: FileListViewModel.stub())
            .environmentObject(MainAppModel.stub())
    }
}
