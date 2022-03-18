//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var fileListViewModel : FileListViewModel
    
    var title : String = ""
    
    init(appModel: MainAppModel, rootFile: VaultFile , fileType: [FileType]? , title : String = "") {
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel,fileType:fileType, rootFile: rootFile ))
        self.title = title
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            
            VStack {
                SelectingFilesHeaderView()
                
                if appModel.vaultManager.root.files.isEmpty {
                    EmptyFileListView(emptyListType: .allFiles)
                    
                } else {
                    
                    FolderListView()
                    
                    if fileListViewModel.rootFile.files.isEmpty {
                        EmptyFileListView(emptyListType: .folder)
                        
                    } else {
                        ManageFileView()
                        FileItemsView(files: fileListViewModel.getFiles())
                    }
                }
            }
            
            AddFileView()
            
            FileSortMenu()
            
            FileActionMenu(fileActionMenuType: fileListViewModel.fileActionMenuType)
            
            showFileDetailsLink
            
            showFileInfoLink
        }
        .toolbar {
            LeadingTitleToolbar(title: title)
        }
        
        .navigationBarHidden(fileListViewModel.shouldHideNavigationBar)
        .environmentObject(fileListViewModel)
    }
    
    @ViewBuilder
    private var showFileDetailsLink: some View {
        if let currentSelectedVaultFile = self.fileListViewModel.currentSelectedVaultFile {
            NavigationLink(destination:
                            FileDetailView(appModel: appModel ,
                                           file: currentSelectedVaultFile,
                                           videoFilesArray: fileListViewModel.rootFile.getVideos().sorted(by: fileListViewModel.sortBy)),
                           isActive: $fileListViewModel.showFileDetails) {
                EmptyView()
            }.frame(width: 0, height: 0)
                .hidden()
        }
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
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
                FileListView(appModel: MainAppModel(),
                             rootFile: VaultFile.stub(type: .folder),
                             fileType: [.folder])
            }
            .background(Styles.Colors.backgroundMain)
        }
        .environmentObject(MainAppModel())
        .environmentObject(FileListViewModel.stub())
    }
}

