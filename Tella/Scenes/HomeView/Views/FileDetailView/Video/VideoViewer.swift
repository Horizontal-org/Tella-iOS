//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @StateObject private var playerVM : PlayerViewModel
    @ObservedObject  var fileListViewModel: FileListViewModel
    init(appModel: MainAppModel,
         currentFile : VaultFileDB?,
         playList: [VaultFileDB?],
         rootFile: VaultFileDB?,
         fileListViewModel: FileListViewModel) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(appModel: appModel,
                                                              currentFile: currentFile,
                                                              playList: playList,
                                                              rootFile: rootFile))
        self.fileListViewModel = fileListViewModel
    }
    
    var body: some View {
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            if !playerVM.videoIsReady {
                ProgressView()
            }
        }
        .onDisappear {
            playerVM.player.pause()
        }
    }
    
    var navigationBarView : some View {
        NavigationHeaderView(title: playerVM.currentFile?.name ?? "",
                             backButtonAction: { backAction() },
                             middleButtonType: .editFile,
                             middleButtonAction: {showEditVideoView()},
                             rightButtonType: .custom,
                             rightButtonView:moreFileActionButton)
    }
    
    var moreFileActionButton : AnyView {
        AnyView(MoreFileActionButton(fileListViewModel: fileListViewModel,
                                     file: playerVM.currentFile,
                                     moreButtonType: .navigationBar))
    }
    
    var contentView: some View {
        VStack {
            CustomVideoPlayer(player: playerVM.player)
                .overlay(CustomVideoControlsView(playerVM: playerVM)
                         ,alignment: .bottom)
            Spacer()
        } 
    }
    
    func backAction() {
        if navigationHasClassType(ViewClassType.fileListView) {
            self.popTo(ViewClassType.fileListView)
        } else {
            self.popToRoot()
        }
        playerVM.deleteTmpFile()
    }
    
    private func showEditVideoView() {
        let viewModel =  EditVideoViewModel(file: playerVM.currentFile, rootFile: playerVM.rootFile, appModel: playerVM.appModel, shouldReloadVaultFiles: .constant(true))
        DispatchQueue.main.async {
            if playerVM.currentFile?.mediaCanBeEdited == true {
                self.present(style: .fullScreen) {
                    EditVideoView(viewModel: viewModel)
                }
            }else {
                Toast.displayToast(message: LocalizableVault.editVideoToastMsg.localized)
            }
        }
    }
}
