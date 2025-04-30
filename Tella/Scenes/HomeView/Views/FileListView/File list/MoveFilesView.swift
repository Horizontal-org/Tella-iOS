//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct MoveFilesView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @ObservedObject var fileListViewModel : FileListViewModel
    
    var title : String = ""
    
    init(title : String = "", fileListViewModel : FileListViewModel) {
        self.title = title
        self.fileListViewModel = fileListViewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Styles.Colors.lightBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                titleView
                
                FolderListView(fileListViewModel: fileListViewModel)
                
                VStack {
                    ManageFileView(fileListViewModel: fileListViewModel)
                    FileItemsView(fileListViewModel: fileListViewModel,
                                  files: fileListViewModel.vaultFiles)
                }
                .background(Color.white.opacity(0.12))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                
                bottomView
            }
            
            AddNewFolderView(fileListViewModel: fileListViewModel)
        }
    }
    
    private var titleView : some View {
        HStack {
            Text(String.init(format: LocalizableVault.moveFileAppBar.localized, title))
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
            Spacer()
        }.padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
    }
    
    private var bottomView : some View {
        HStack {
            cancelButton
            
            Spacer()
            
            Image("files.move-separator")
                .frame(height: 50)
            
            Spacer()
            
            moveButton
            
        }.frame(height: 50)
    }
    
    var cancelButton: some View {
        Button {
            fileListViewModel.showingMoveFileView  = false
            fileListViewModel.resetSelectedItems()
            fileListViewModel.initFolderPathArray()
            fileListViewModel.rootFile = fileListViewModel.oldParentFile
        } label: {
            Text(LocalizableVault.moveFileActionCancel.localized)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
        }
    }
    
    var moveButton: some View {
        Button {
            fileListViewModel.showingMoveFileView  = false
            fileListViewModel.moveFiles()
            fileListViewModel.resetSelectedItems()
        } label: {
            Text(LocalizableVault.moveFileActionMove.localized)
                .foregroundColor( fileListViewModel.oldParentFile == fileListViewModel.rootFile ? .white.opacity(0.4) : .white)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.disabled(fileListViewModel.oldParentFile == fileListViewModel.rootFile)
    }
}

struct MoveFilesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Styles.Colors.lightBlue.edgesIgnoringSafeArea(.all)
            MoveFilesView(title: "Move “IMG9092.jpg”", fileListViewModel: FileListViewModel.stub())
        }
        .environmentObject(MainAppModel.stub())
    }
}
