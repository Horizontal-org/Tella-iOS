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
        
        NavigationContainerView {
            
            ZStack(alignment: .top) {
                
                VStack {
                    
                    headerView
                    
                    SelectingFilesHeaderView()
                    
                    if (fileListViewModel.vaultFiles.isEmpty) && fileListViewModel.rootFile == nil  {
                        EmptyFileListView(emptyListType: .allFiles)
                        
                    } else {
                        if fileListViewModel.folderPathArray.count > 0 {
                            FolderListView()
                        }
                        if fileListViewModel.vaultFiles.isEmpty {
                            EmptyFileListView(emptyListType: .directory)
                            
                        } else {
                            ManageFileView()
                            FileItemsView(files: fileListViewModel.vaultFiles)
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
        .onAppear(perform: {
            fileListViewModel.fileActionSource = .listView
        })
    }
    
    var fileDetailView: some View {
        FileDetailsView(appModel: appModel, currentFile: fileListViewModel.selectedFiles.first)
            .environmentObject(fileListViewModel)
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
                        .flipsForRightToLeftLayoutDirection(true)
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
            FileListView(appModel: MainAppModel.stub(),
                         rootFile: VaultFileDB.stub(),
                         filterType: .all)
        }
        .background(Styles.Colors.backgroundMain)
        .environmentObject(MainAppModel.stub())
        .environmentObject(FileListViewModel.stub())
    }
}
