//
//  Copyright © 2021 INTERNEWS. All rights reserved.
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
        showFileInfoLink
    }

    @ViewBuilder
    private var showFileInfoLink : some View{
        if let currentSelectedVaultFile = fileListViewModel.currentSelectedVaultFile {
            NavigationLink(destination:
                            FileInfoView(viewModel: self.fileListViewModel, file: currentSelectedVaultFile),
                           isActive: $fileListViewModel.showFileInfoActive) {
                EmptyView()
            }.frame(width: 0, height: 0)
                .hidden()
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
