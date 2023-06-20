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
        
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                if !fileListViewModel.showingMoveFileView {
                    if !fileListViewModel.selectingFiles && !fileListViewModel.shouldHideViewsForGallery {
                        MoreFileActionButton(file: file, moreButtonType: .grid)
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
        FileGridItem(file: VaultFile.stub(type: .folder))
            .environmentObject(MainAppModel.stub())
            .environmentObject(FileListViewModel.stub())
        
    }
}

