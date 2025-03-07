//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ManageFileView: View {
    
    @ObservedObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            
            FileSortMenu(fileListViewModel: fileListViewModel)
            
            Spacer()
            
            selectingFilesButton
            
            Spacer()
                .frame(width: 5)
            
            viewTypeButton
        }
        .padding(EdgeInsets(top: 0, leading: fileListViewModel.showingMoveFileView ? 8 : 16 , bottom: 0, trailing: fileListViewModel.showingMoveFileView ? 8 : 12))
    }
    
    @ViewBuilder
    private var selectingFilesButton: some View {
        
        if !fileListViewModel.showingMoveFileView {
            
            Button {
                manageSelectionFiles()
            } label: {
                
                HStack {
                    if fileListViewModel.selectingFiles {
                        Image(fileListViewModel.filesAreAllSelected ? "files.selected" : "files.unselected")
                    } else {
                        Image("files.select")
                    }
                }
            }
            .frame(width: 50, height: 50)
        }
    }
    
    @ViewBuilder
    private var viewTypeButton: some View {
        if !fileListViewModel.shouldHideViewsForGallery {
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
    
    private func manageSelectionFiles() {
        DispatchQueue.main.async {
            if fileListViewModel.selectingFiles {
                fileListViewModel.filesAreAllSelected ? fileListViewModel.resetSelectedItems() :  fileListViewModel.selectAll()
            } else {
                fileListViewModel.selectingFiles = !fileListViewModel.selectingFiles
                fileListViewModel.initVaultFileStatusArray()
            }
        }
    }
    
}

struct ManageFileView_Previews: PreviewProvider {
    static var previews: some View {
        ManageFileView(fileListViewModel: FileListViewModel.stub())
    }
}
