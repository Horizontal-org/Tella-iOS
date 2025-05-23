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
                CircularActivityIndicatory()
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
                             isMiddleButtonEnabled: playerVM.videoIsReady,
                             rightButtonType: .custom,
                             rightButtonView:moreFileActionButton)
    }
    
    var moreFileActionButton : AnyView {
        AnyView(MoreFileActionButton(fileListViewModel: fileListViewModel,
                                     file: playerVM.currentFile,
                                     moreButtonType: .navigationBar)
            .opacity(playerVM.videoIsReady ? 1 : 0.4)
            .disabled(!playerVM.videoIsReady))
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
                                            fileURL: playerVM.currentVideoURL,
                                            rootFile: playerVM.rootFile,
                                            appModel: playerVM.appModel,
                                            editMedia: EditVideoParameters())
        DispatchQueue.main.async {
            self.present(style: .fullScreen) {
                EditVideoView(viewModel: viewModel)
            }
        }
    }
}
