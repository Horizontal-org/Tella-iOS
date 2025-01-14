//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @StateObject private var playerVM : PlayerViewModel
    
    init(appModel: MainAppModel, currentFile : VaultFileDB?, playList: [VaultFileDB?], rootFile: VaultFileDB?) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(appModel: appModel,
                                                              currentFile: currentFile,
                                                              playList: playList,
                                                              rootFile: rootFile))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomVideoPlayer(player: playerVM.player)
                    .overlay(CustomVideoControlsView(playerVM: playerVM)
                             ,alignment: .bottom)
                
            }
            if !playerVM.videoIsReady {
                ProgressView()
            }
        }
        .toolbar {
            LeadingTitleToolbar(title: playerVM.currentFile?.name ?? "")
            fileActionTrailingView()
        }
        .onDisappear {
            playerVM.player.pause()
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        
    }
    
    func fileActionTrailingView() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                Button {
                    self.showEditVideoView()
                } label: {
                    Image("file.edit")
                }
                MoreFileActionButton(file: playerVM.currentFile, moreButtonType: .navigationBar)
            }
        }
    }
    
    var backButton : some View {
        BackButton {
            playerVM.deleteTmpFile()
        }
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

struct BackButton: View {
    
    var action : (() -> ())
    
    var body: some View {
        Button {
            if navigationHasClassType(ViewClassType.fileListView) {
                self.popTo(ViewClassType.fileListView)
            } else {
                self.popToRoot()
            }
            
            action()
        } label: {
            Image("back")
                .flipsForRightToLeftLayoutDirection(true)
                .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
        }
    }
}
