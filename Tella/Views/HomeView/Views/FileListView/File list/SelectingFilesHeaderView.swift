//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SelectingFilesHeaderView: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel

    var body: some View {
        if  fileListViewModel.selectingFiles {
            HStack{
                Button {
                    fileListViewModel.selectingFiles = false
                    fileListViewModel.resetSelectedItems()
                } label: {
                    Image("close")
                }
                
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width: 12)
                if fileListViewModel.selectedItemsNumber > 0 {
                    
                    Text(fileListViewModel.selectedItemsTitle)
                        .foregroundColor(.white).opacity(0.8)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                }
                Spacer(minLength: 15)
                
                Button {
                     fileListViewModel.selectAll()
                } label: {
                    Image("add-to-library")
                }
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width:30)
                
                Button {
                    fileListViewModel.fileActionMenuType = .multiple
                    fileListViewModel.showingFileActionMenu = true
                } label: {
                    Image("files.more")
                        .renderingMode(.template)
                        .foregroundColor((fileListViewModel.selectedItemsNumber == 0) ? .white.opacity(0.5) : .white)
                    
                }.disabled(fileListViewModel.selectedItemsNumber == 0)
                    .frame(width: 24, height: 24)
                
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 23))
        }    }
}

struct SelectingFilesHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingFilesHeaderView()
    }
}
