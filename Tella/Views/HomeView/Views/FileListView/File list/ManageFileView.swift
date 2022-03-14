//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ManageFileView: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            
            sortFilesButton
            
            Spacer()
            
            if !fileListViewModel.showingMoveFileView {
                selectingFilesButton
            }
            
            Spacer()
                .frame(width: 5)
            
            viewTypeButton
        }
        .padding(EdgeInsets(top: 0, leading: fileListViewModel.showingMoveFileView ? 16 : 8, bottom: 0, trailing: fileListViewModel.showingMoveFileView ? 12 : 8))

    }
    
    
    private var sortFilesButton: some View {
        Button {
            fileListViewModel.showingSortFilesActionSheet = true
        } label: {
            HStack{
                Text(fileListViewModel.sortBy.displayName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14) )
                    .foregroundColor(.white)
                fileListViewModel.sortBy.image
                    .frame(width: 20, height: 20)
            }
        }
        .frame(height: 44)
    }
    
    private var selectingFilesButton: some View {
        Button {
            
            fileListViewModel.selectingFiles = !fileListViewModel.selectingFiles
            if fileListViewModel.selectingFiles {
                fileListViewModel.initVaultFileStatusArray()
            }
            fileListViewModel.resetSelectedItems()
            
        } label: {
            HStack{
                Image(fileListViewModel.selectingFiles ? "files.selected" : "files.unselected-empty")
                
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 50, height: 50)
    }
    
    private var viewTypeButton: some View {
        Button {
            fileListViewModel.viewType = fileListViewModel.viewType == .list ? FileViewType.grid : FileViewType.list
        } label: {
            HStack{
                fileListViewModel.viewType.image
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 50, height: 50)
    }
    
}

struct ManageFileView_Previews: PreviewProvider {
    static var previews: some View {
        ManageFileView()
    }
}
