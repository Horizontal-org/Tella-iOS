//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var fileListViewModel : FileListViewModel
    @State var showFileDetails : Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title : String = ""
    
    init(appModel: MainAppModel, rootFile: VaultFile , fileType: [FileType]? , title : String = "", fileListType : FileListType = .fileList, resultFile: Binding<[VaultFile]?>? = nil) {
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel,fileType:fileType, rootFile: rootFile, folderPathArray: [], fileListType :  fileListType, resultFile: resultFile))
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
                    if fileListViewModel.folderPathArray.count > 0 {
                        FolderListView()
                    }
                    if fileListViewModel.getFiles().isEmpty {
                        EmptyFileListView(emptyListType: .folder)
                        
                    } else {
                        ManageFileView()
                        FileItemsView(files: fileListViewModel.getFiles())
                    }
                }
            }
            
            if !fileListViewModel.shouldHideAddFileButton {
                AddFileView()
            }
            
            FileActionMenu()
            
            showFileDetailsLink
        }
        .toolbar {
            LeadingTitleToolbar(title: title)
            selectFilesButton()
        }
        .navigationBarHidden(fileListViewModel.shouldHideNavigationBar)
        .environmentObject(fileListViewModel)
    }

    @ToolbarContentBuilder
    func selectFilesButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                fileListViewModel.attachFiles()
                presentationMode.wrappedValue.dismiss()

                
            } label: {
                Image("report.select-files")
            }
        }
    }

    @ViewBuilder
    private var showFileDetailsLink: some View {
        if let currentSelectedVaultFile = self.fileListViewModel.currentSelectedVaultFile {
            
            FileDetailView(appModel: appModel ,
                           file: currentSelectedVaultFile,
                           videoFilesArray: fileListViewModel.rootFile.getVideos().sorted(by: fileListViewModel.sortBy),
                           rootFile: fileListViewModel.rootFile,
                           folderPathArray: fileListViewModel.folderPathArray)
            .addNavigationLink(isActive: $fileListViewModel.showFileDetails)
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

