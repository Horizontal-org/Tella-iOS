//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FolderListView: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    @EnvironmentObject var appModel: MainAppModel
    
    var body: some View {
        HStack(spacing: 5) {
            
            if fileListViewModel.folderArray.count > 0 {
                Button() {
                    fileListViewModel.rootFile = appModel.vaultManager.root
                    fileListViewModel.folderArray.removeAll()
                } label: {
                    Image("files.folder")
                        .resizable()
                        .frame(width: 20, height: 16)
                }.padding(7)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    
                    if !fileListViewModel.folderArray.isEmpty {
                        Image("files.arrow_right")
                            .resizable()
                            .frame(width: 7, height: 11)
                    }
                    
                    ForEach(fileListViewModel.folderArray, id:\.self) { file in
                        
                        Button {
                            fileListViewModel.rootFile = file
                            
                            // Remove the next folders after the selected folder
                            if let index = fileListViewModel.folderArray.firstIndex(of: file) {
                                fileListViewModel.folderArray.removeSubrange(index + 1..<fileListViewModel.folderArray.endIndex)
                            }
                            
                        } label: {
                            Text(file.fileName)
                                .foregroundColor(.white).opacity(0.72)
                                .font(.custom(Styles.Fonts.regularFontName, size: 16))
                        }
                        .padding(7)
                        
                        if let index = fileListViewModel.folderArray.firstIndex(of: file), index < fileListViewModel.folderArray.count  - 1 {
                            Image("files.arrow_right")
                                .resizable()
                                .frame(width: 7, height: 11)
                        }
                    }
                }
            }
            
        }.padding(EdgeInsets(top: 12, leading: 18, bottom: 15, trailing: 18))
    }
}

struct FolderListView_Previews: PreviewProvider {
    static var previews: some View {
        FolderListView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
