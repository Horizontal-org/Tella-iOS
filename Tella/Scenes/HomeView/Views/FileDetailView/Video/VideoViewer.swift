//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject private var playerVM : PlayerViewModel
    
    init(appModel: MainAppModel, currentFile : VaultFileDB?, playList: [VaultFileDB?]) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(appModel: appModel,
                                                              currentFile: currentFile,
                                                              playList: playList))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomVideoPlayer(playerVM: playerVM)
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
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)

    }
    
    func fileActionTrailingView() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            MoreFileActionButton(file: playerVM.currentFile, moreButtonType: .navigationBar)
        }
    }
    
    var backButton : some View {
        BackButton {
            playerVM.deleteTmpFile()
        }
    }
}

struct BackButton: View {
    
    var action : (() -> ())
    
    var body: some View {
             Button {
                self.popToRoot()
                 action()
            } label: {
                Image("back")
                    .flipsForRightToLeftLayoutDirection(true)
                    .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
            }
 
    }
}

