//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileActionMenu: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isPresented = true
    
    var body: some View {
        fileDocumentExporter
        if fileListViewModel.showingMoveFileView {
            moveFilesView
        }
        ShareFileView()
        showFileInfoLink
    }
    
    var fileDocumentExporter: some View {
        ZStack {
            
        }
        .sheet(isPresented: $fileListViewModel.showingDocumentPicker, onDismiss: {
            appModel.vaultManager.clearTmpDirectory()
        }, content: {
            DocumentPickerView(documentPickerType: .forExport,
                               URLs: appModel.vaultManager.load(files: fileListViewModel.selectedFiles) ?? [] ) { _ in
            }
        })
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
        MoveFilesView(title: fileListViewModel.fileActionsTitle)
    }
}

struct FileActionMenu_Previews: PreviewProvider {
    static var previews: some View {
        FileActionMenu()
            .environmentObject(MainAppModel.stub())
            .environmentObject(FileListViewModel.stub())
    }
}
