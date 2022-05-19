//
//  FileGridItem.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileGridItem: View {
    
    var file: VaultFile
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        
        Button {
            if !fileListViewModel.selectingFiles {
                fileListViewModel.showFileDetails(file: file)
            }
        } label: {
            fileGridView
        }
    }
    
    var fileGridView : some View {
        
        ZStack {
            
            file.gridImage
            
            VStack(alignment: .trailing) {
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    if !fileListViewModel.showingMoveFileView {
                        selectionButton
                    }
                }
            }
            self.fileNameText
            
            selectingFilesView
        }
    }
    
    @ViewBuilder
    var fileNameText: some View {
        
        if !fileListViewModel.shouldHideViewsForGallery {
            
            if self.file.type != .image || self.file.type != .video {
                VStack {
                    Spacer()
                    Text(self.file.fileName)
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
        if !fileListViewModel.selectingFiles && !fileListViewModel.shouldHideViewsForGallery {
            MoreFileActionButton(file: file, moreButtonType: .grid)
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
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 0, trailing: 0))
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
        FileGridItem(file: VaultFile.stub(type: .folder))
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
        
    }
}

