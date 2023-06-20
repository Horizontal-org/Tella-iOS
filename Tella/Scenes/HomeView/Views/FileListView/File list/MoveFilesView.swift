//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct MoveFilesView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
    var title : String = ""
    
    init(title : String = "") {
        self.title = title
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Styles.Colors.lightBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                titleView
                
                FolderListView()
                
                VStack {
                    ManageFileView()
                    FileItemsView(files: fileListViewModel.getFiles())
                }
                .background(Color.white.opacity(0.12))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                
                bottomView
            }
            
            AddNewFolderView()
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
            fileListViewModel.initSelectedFiles()
            fileListViewModel.initFolderPathArray()
            fileListViewModel.rootFile = fileListViewModel.oldRootFile
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
            fileListViewModel.initSelectedFiles()
        } label: {
            Text(LocalizableVault.moveFileActionMove.localized)
                .foregroundColor( fileListViewModel.oldRootFile == fileListViewModel.rootFile ? .white.opacity(0.4) : .white)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.disabled(fileListViewModel.oldRootFile == fileListViewModel.rootFile)
    }
}

struct MoveFilesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Styles.Colors.lightBlue.edgesIgnoringSafeArea(.all)
            MoveFilesView(title: "Move “IMG9092.jpg”")
        }
        .environmentObject(MainAppModel.stub())
        .environmentObject(FileListViewModel.stub())
    }
}
