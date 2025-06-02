//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SelectingFilesHeaderView: View {
    
    @ObservedObject var fileListViewModel : FileListViewModel
    
    var body: some View {
        if  fileListViewModel.shouldShowSelectingFilesHeaderView  {
            NavigationHeaderView(title: fileListViewModel.selectedItemsNumber > 0 ? fileListViewModel.selectedItemsTitle : "",
                                 backButtonType: .close,
                                 backButtonAction: { backAction() },
                                 middleButtonType: fileListViewModel.shouldShowShareButton ? .share : .none,
                                 middleButtonAction: {showActivityViewController()},
                                 rightButtonType: fileListViewModel.selectedItemsNumber > 0 ? .custom : .none,
                                 rightButtonView:moreFileActionButton)
        }
    }
    
    var moreFileActionButton : AnyView {
        AnyView(MoreFileActionButton(fileListViewModel: fileListViewModel,
                                     moreButtonType: .navigationBar))
    }
    
    func backAction() {
        fileListViewModel.selectingFiles = false
        fileListViewModel.resetSelectedItems()
    }
    
    func showActivityViewController() {
        self.present(style: .pageSheet) {
            ActivityViewController(fileData: fileListViewModel.getDataToShare())
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct SelectingFilesHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingFilesHeaderView(fileListViewModel: FileListViewModel.stub())
            .background(Styles.Colors.backgroundMain)
    }
}
