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
            
            VStack {
                
                titleView
                
                FolderListView()
                
                VStack {
                    ManageFileView()
                    FileItemsView(files: fileListViewModel.getFiles())
                }
                .background(Color.white.opacity(0.12))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                
                Spacer()
                
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

            Button(LocalizableVault.moveFileActionCancel.localized) {
                fileListViewModel.showingMoveFileView  = false
                fileListViewModel.initSelectedFiles()
                fileListViewModel.initFolderPathArray()
                fileListViewModel.rootFile = fileListViewModel.oldRootFile
            } .buttonStyle(MoveFileButtonStyle())
                .foregroundColor(.white)
            
            Button(LocalizableVault.moveFileActionMove.localized) {
                fileListViewModel.showingMoveFileView  = false
                fileListViewModel.moveFiles()
                fileListViewModel.initSelectedFiles()
            }.foregroundColor( fileListViewModel.oldRootFile == fileListViewModel.rootFile ? .white.opacity(0.4) : .white)
                .disabled(fileListViewModel.oldRootFile == fileListViewModel.rootFile)
                .buttonStyle(MoveFileButtonStyle())
        }.frame(height: 50)
    }
}

struct MoveFileButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(Styles.Fonts.boldFontName, size: 16))
            .frame(maxWidth: .infinity)
    }
}


struct MoveFilesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Styles.Colors.lightBlue.edgesIgnoringSafeArea(.all)
                MoveFilesView(title: "Move “IMG9092.jpg”")
            }
        }
        .environmentObject(MainAppModel())
        .environmentObject(FileListViewModel.stub())
    }
}
