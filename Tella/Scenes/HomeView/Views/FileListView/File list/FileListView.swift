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
        
        NavigationContainerView {

            //        ZStack(alignment: .top) {
            
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            
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
            
            showFileDetailsLink
//        }
//        .toolbar {
//            LeadingTitleToolbar(title: title)
//            selectFilesButton()
//        }
//        .navigationBarHidden(fileListViewModel.shouldHideNavigationBar)
        }
        .navigationBarHidden(true)

        .environmentObject(fileListViewModel)
    }
    
//    @ToolbarContentBuilder
//    func selectFilesButton() -> some ToolbarContent {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button {
//                fileListViewModel.attachFiles()
//                presentationMode.wrappedValue.dismiss()
//            } label: {
//                Image("report.select-files")
//            }
//        }
//    }
    
    @ViewBuilder
    var headerView: some View {
        if !fileListViewModel.shouldHideNavigationBar {
            HStack(spacing: 0) {
                Button {
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

//    @ToolbarContentBuilder
//    func selectFilesButton() -> some ToolbarContent {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button {
//                fileListViewModel.attachFiles()
//                presentationMode.wrappedValue.dismiss()
//
//
//            } label: {
//                Image("report.select-files")
//            }
//        }
//    }

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

