//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var fileListViewModel : FileListViewModel
    @State var showFileDetails : Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var navigationBarIsHidden : Bool = true
    
    var title : String = ""
    
    init(appModel: MainAppModel, rootFile: VaultFile , fileType: [TellaFileType]? , title : String = "", fileListType : FileListType = .fileList, resultFile: Binding<[VaultFile]?>? = nil) {
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel,fileType:fileType, rootFile: rootFile, folderPathArray: [], fileListType :  fileListType, resultFile: resultFile))
        self.title = title
    }
    
    var body: some View {
        
        NavigationContainerView {
            
            ZStack(alignment: .top) {
                
                VStack {
                    
                    headerView
                    
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
                
                
            }.environmentObject(fileListViewModel)
        }
        .navigationBarHidden(navigationBarIsHidden)
        
        .environmentObject(fileListViewModel)
        
        .onReceive(fileListViewModel.$showFileDetails) { value in
            if value {
                navigateTo(destination: fileDetailView)
            }
        }
    }
    
    var fileDetailView: some View {
        FileDetailView(appModel: appModel ,
                       file: self.fileListViewModel.currentSelectedVaultFile,
                       videoFilesArray: fileListViewModel.rootFile.getVideos().sorted(by: fileListViewModel.sortBy),
                       rootFile: fileListViewModel.rootFile,
                       folderPathArray: fileListViewModel.folderPathArray)
    }
    
    @ViewBuilder
    var headerView: some View {
        if !fileListViewModel.shouldHideNavigationBar {
            HStack(spacing: 0) {
                Button {
                    navigationBarIsHidden = false
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    Image("back")
                        .padding()
                }
                
                Text(title)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                if  fileListViewModel.fileListType == .selectFiles {
                    
                    Button {
                        fileListViewModel.attachFiles()
                        presentationMode.wrappedValue.dismiss()
                        
                        
                    } label: {
                        Image("report.select-files")
                    }.padding(.trailing, 15)
                    
                }
            }.frame(height: 56)
        }
    }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            FileListView(appModel: MainAppModel(),
                         rootFile: VaultFile.stub(type: .folder),
                         fileType: [.folder])
        }
        .background(Styles.Colors.backgroundMain)
        .environmentObject(MainAppModel())
        .environmentObject(FileListViewModel.stub())
    }
}
