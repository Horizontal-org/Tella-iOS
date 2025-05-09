//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
            Spacer()
            
            CustomVideoPlayer(player: playerVM.player,
                              rotationAngle: .constant(0))
            Spacer()
                .frame(height: 20)
            CustomVideoControlsView(playerVM: playerVM)
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
        let viewModel =  EditVideoViewModel(file: playerVM.currentFile,
                                            rootFile: playerVM.rootFile,
                                            appModel: playerVM.appModel,
                                            editMedia: EditVideoParameters())
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
