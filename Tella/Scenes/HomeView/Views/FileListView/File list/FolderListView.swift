//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FolderListView: View {
    
    @ObservedObject var fileListViewModel : FileListViewModel
    @EnvironmentObject var appModel: MainAppModel
    
    var body: some View {
        HStack(spacing: 5) {
            
            if fileListViewModel.folderPathArray.count > 0 {
                Button() {
                    fileListViewModel.rootFile = nil
                    fileListViewModel.folderPathArray.removeAll()
                    fileListViewModel.selectingFiles = false
                } label: {
                    Image("files.folder")
                        .resizable()
                        .frame(width: 20, height: 16)
                }.padding(7)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    
                    if !fileListViewModel.folderPathArray.isEmpty {
                        Image("files.arrow_right")
                            .resizable()
                            .frame(width: 7, height: 11)
                    }
                    
                    ForEach(fileListViewModel.folderPathArray, id:\.self) { file in
                        
                        Button {
                            fileListViewModel.rootFile = file
                            
                            // Remove the next folders after the selected folder
                            fileListViewModel.initFolderPathArray(for: file)
                            fileListViewModel.selectingFiles = false
                        } label: {
                            Text(file.name)
                                .foregroundColor(.white).opacity(0.72)
                                .font(.custom(Styles.Fonts.regularFontName, size: 16))
                        }
                        .padding(7)
                        
                        if let index = fileListViewModel.folderPathArray.firstIndex(of: file), index < fileListViewModel.folderPathArray.count  - 1 {
                            Image("files.arrow_right")
                                .resizable()
                                .frame(width: 7, height: 11)
                        }
                    }
                }
            }
            
        }.padding(EdgeInsets(top: 12, leading: 10, bottom: 0, trailing: 18))
    }
}

struct FolderListView_Previews: PreviewProvider {
    static var previews: some View {
        FolderListView(fileListViewModel: FileListViewModel.stub())
            .background(Styles.Colors.backgroundMain)
            .environmentObject(MainAppModel.stub())
    }
}
