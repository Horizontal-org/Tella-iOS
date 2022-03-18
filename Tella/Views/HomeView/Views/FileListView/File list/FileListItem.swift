//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListItem: View {
    
    var file: VaultFile
//     @State var isSelected : Bool = false

    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel : FileListViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(alignment: .center, spacing: 0){
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
                        Text(file.fileName)
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
                    .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0))
                    
                    Spacer()
                    
                    if !fileListViewModel.showingMoveFileView {
                        selectionButton
                    }
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
            .background((fileListViewModel.getStatus(for: file) && fileListViewModel.selectingFiles) ? Color.white.opacity(0.16) : Color.white.opacity(0.001))
        }
    }
    
    @ViewBuilder
    var selectionButton : some View {
        
        if fileListViewModel.selectingFiles {
            HStack {
                Image(fileListViewModel.getStatus(for: file) ? "files.selected" : "files.unselected")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
            
            
        } else {
            Button {
                fileListViewModel.showingFileActionMenu = true
                fileListViewModel.updateSingleSelection(for: file)
            } label: {
                Image("files.more")
                    .resizable()
                    .frame(width: 20, height: 20)
            }.frame(width: 40, height: 40)
        }
        
        
        

    }

}

struct FileListItem_Previews: PreviewProvider {
    static var previews: some View {
        FileListItem(file: VaultFile.stub(type: .folder))
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}

