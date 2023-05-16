//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SelectingFilesHeaderView: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        if  fileListViewModel.shouldShowSelectingFilesHeaderView  {
           
            HStack{
                
                closeButton
                
                Spacer()
                    .frame(width: 12)
                
                itemsTitle
                
                Spacer(minLength: 15)
                
                if fileListViewModel.selectedItemsNumber > 0 {
                    
                    shareButton
                    
                    Spacer()
                        .frame(width:30)
                    
                    MoreFileActionButton(moreButtonType: .navigationBar)
                }
                
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 23))
                .frame( height: 45)
        }
    }
    
    var closeButton: some View {
        Button {
            fileListViewModel.selectingFiles = false
            fileListViewModel.resetSelectedItems()
        } label: {
            Image("close")
        }
        .frame(width: 24, height: 24)
    }
    
    @ViewBuilder
    var itemsTitle: some View {
        if fileListViewModel.selectedItemsNumber > 0 {
            
            Text(fileListViewModel.selectedItemsTitle)
                .foregroundColor(.white).opacity(0.8)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if fileListViewModel.shouldActivateShare {
            
            Button {
                fileListViewModel.showingShareFileView = true
            } label: {
                Image("share-icon")
            }
            .frame(width: 24, height: 24)
        }
    }
}

struct SelectingFilesHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingFilesHeaderView()
    }
}
