//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FileListItem: View {
    
    var file: VaultFileDB

    @ObservedObject var fileListViewModel : FileListViewModel
    
    var backgroundColor : Color {
        (fileListViewModel.getStatus(for: file) && fileListViewModel.selectingFiles) ? Color.white.opacity(0.16) : Styles.Colors.backgroundMain.opacity(0.001)
    }
    
    var body: some View {
        ZStack {
            
            Button {
                if !fileListViewModel.selectingFiles {
                    fileListViewModel.showFileDetails(file: file)
                }
            } label: {
                fileListView
            }
            .buttonStyle(FileListItemButtonStyle(backgroundColor: backgroundColor))
            
            selectionButton
        }
    }
    
    var fileListView : some View {
        
        GeometryReader { geometry in
            ZStack {
                HStack(alignment: .center, spacing: 0) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 35, height: 35, alignment: .center)
                        .overlay(
                            file.listImage
                                .frame(width: 35, height: 35)
                                .cornerRadius(5)
                        )
                    VStack(alignment: .leading, spacing: 0){
                        Spacer()
                        Text(file.name)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                        
                        Spacer()
                            .frame(height: 2)
                        
                        Text(file.formattedCreationDate)
                            .font(.custom(Styles.Fonts.regularFontName, size: 10))
                            .foregroundColor(Color.white)
                        
                        Spacer()
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 40))
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: fileListViewModel.showingMoveFileView ? 8 : 16, bottom: 12, trailing: fileListViewModel.showingMoveFileView ? 8 : 16))
                .frame(height: 60)
                
                
                if fileListViewModel.selectingFiles {
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onTapGesture {
                            fileListViewModel.updateSelection(for: file)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    var selectionButton : some View {
        HStack {
            Spacer()
            if !fileListViewModel.showingMoveFileView {
                if fileListViewModel.selectingFiles {
                    HStack {
                        Image(fileListViewModel.getStatus(for: file) ? "files.selected" : "files.unselected")
                    }
                    .frame(width: 40, height: 40)
                } else {
                    MoreFileActionButton(fileListViewModel: fileListViewModel,
                                         file: file,
                                         moreButtonType: .list)
                }
            }
        }
        .padding(EdgeInsets(top: 12, leading: fileListViewModel.showingMoveFileView ? 8 : 16, bottom: 12, trailing: fileListViewModel.showingMoveFileView ? 8 : 16))
        .frame(height: 60)
    }
}

struct FileListItemButtonStyle : ButtonStyle {
    
    let backgroundColor : Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.20) : backgroundColor)
    }
}

struct FileListItem_Previews: PreviewProvider {
    static var previews: some View {
        FileListItem(file: VaultFileDB.stub(), fileListViewModel: FileListViewModel.stub())
    }
}

