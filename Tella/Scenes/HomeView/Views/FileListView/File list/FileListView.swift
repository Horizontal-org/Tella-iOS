//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var fileListViewModel : FileListViewModel
    @State var showFileDetails : Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var title : String = ""
    
    init(appModel: MainAppModel,
         rootFile: VaultFileDB? = nil ,
         filterType: FilterType ,
         title : String = "",
         fileListType : FileListType = .fileList,
         resultFile: Binding<[VaultFileDB]?>? = nil) {
        
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel,
                                                                         filterType:filterType,
                                                                         rootFile: rootFile,
                                                                         fileListType : fileListType,
                                                                         resultFile: resultFile))
        self.title = title
    }
    
    var body: some View {
        
        ContainerViewWithHeader {
            
            VStack {
                navigationBarView
                SelectingFilesHeaderView(fileListViewModel: fileListViewModel)
            }
        } content: {
            contentView
        }
        .onReceive(fileListViewModel.$showFileDetails) { value in
            if value {
                navigateTo(destination: fileDetailView)
            }
        }
        .onAppear(perform: {
            fileListViewModel.fileActionSource = .listView
        })
    }
    
    var contentView: some View {
        
        ZStack(alignment: .top) {
            
            VStack {
                
                if (fileListViewModel.vaultFiles.isEmpty) && fileListViewModel.rootFile == nil  {
                    EmptyFileView(message: LocalizableVault.emptyAllFilesExpl.localized)
                    
                } else {
                    if fileListViewModel.folderPathArray.count > 0 {
                        FolderListView(fileListViewModel: fileListViewModel)
                    }
                    if fileListViewModel.vaultFiles.isEmpty {
                        EmptyFileView(message: LocalizableVault.emptyFolderExpl.localized)
                        
                    } else {
                        ManageFileView(fileListViewModel: fileListViewModel)
                        FileItemsView(fileListViewModel: fileListViewModel, files: fileListViewModel.vaultFiles)
                    }
                }
            }
            
            if !fileListViewModel.shouldHideAddFileButton {
                AddFileView(fileListViewModel: fileListViewModel)
            }
            
            FileActionMenu(fileListViewModel: fileListViewModel)
        }
    }
    
    var fileDetailView: FileDetailsView {
        FileDetailsView(appModel: appModel, currentFile: fileListViewModel.selectedFiles.first,fileListViewModel:fileListViewModel)
    }
    
    @ViewBuilder
    var navigationBarView: some View {
        
        if !fileListViewModel.shouldHideNavigationBar {
            
            NavigationHeaderView(title: title,
                                 rightButtonType: fileListViewModel.shouldShowSelectButton ? .validate : .none,
                                 rightButtonAction: { attachFiles()})
        }
    }
    
    func attachFiles() {
        fileListViewModel.attachFiles()
        presentationMode.wrappedValue.dismiss()
    }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            FileListView(appModel: MainAppModel.stub(),
                         rootFile: VaultFileDB.stub(),
                         filterType: .all)
        }
        .background(Styles.Colors.backgroundMain)
        .environmentObject(MainAppModel.stub())
    }
}
