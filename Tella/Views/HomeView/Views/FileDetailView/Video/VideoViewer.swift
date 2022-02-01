//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @ObservedObject var appModel: MainAppModel
    @StateObject private var playerVM = PlayerViewModel()
    
    var currentFile : VaultFile
    var playlist: [VaultFile?]
    
    var body: some View {
        VStack {
            VStack {
                CustomVideoPlayer(playerVM: playerVM)
                    .overlay(CustomVideoControlsView(playerVM: playerVM)
                                ,alignment: .bottom)
            }
        }
        .onAppear {
            playerVM.appModel = appModel
            if let index = playlist.firstIndex(of: currentFile) {
                playerVM.currentItemIndex = index
            }
            playerVM.playList = playlist
        }
        .onDisappear {
            appModel.vaultManager.clearTmpDirectory()
        }
    }
}
