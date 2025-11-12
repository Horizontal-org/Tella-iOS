//
//  FileGridItem.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FileGridItem: View {
    
    var file: VaultFileDB

    @ObservedObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        ZStack {
            
            Button {
                if !fileListViewModel.selectingFiles {
                    fileListViewModel.showFileDetails(file: file)
                }
            } label: {
                fileGridView
            }
            
            selectionButton
        }
    }
    
    var fileGridView : some View {
        
        ZStack {
            
            file.gridImage
            
            self.fileNameText
            
            selectingFilesView
        }
    }
    
    @ViewBuilder
    var fileNameText: some View {
        
        if !fileListViewModel.shouldHideViewsForGallery {
            
            if self.file.tellaFileType != .image || self.file.tellaFileType != .video {
                VStack {
                    Spacer()
                    Text(self.file.name)
                        .font(.custom(Styles.Fonts.regularFontName, size: 11))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                        .frame(height: 6)
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 18))
            }
        }
    }
    
    @ViewBuilder
    var selectionButton: some View {
        
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                if !fileListViewModel.showingMoveFileView {
                    if !fileListViewModel.selectingFiles && !fileListViewModel.shouldHideViewsForGallery {
                        MoreFileActionButton(fileListViewModel: fileListViewModel,
                                             file: file, moreButtonType: .grid)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var selectingFilesView: some View {
        if fileListViewModel.selectingFiles {
            GeometryReader { geometryReader in
                
                Color.black.opacity(0.32)
                    .onTapGesture {
                        fileListViewModel.updateSelection(for: file)
                    }
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                
                HStack() {
                    
                    VStack(alignment: .leading) {
                        Image(fileListViewModel.getStatus(for: file) ? "files.selected" : "files.unselected")
                            .frame(width: 25, height: 25)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                        Spacer()
                        
                    }.onTapGesture {
                        fileListViewModel.updateSelection(for: file)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct FileGridItem_Previews: PreviewProvider {
    static var previews: some View {
        FileGridItem(file: VaultFileDB.stub(), fileListViewModel: FileListViewModel.stub())
    }
}

