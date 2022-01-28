//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @ObservedObject var appModel: MainAppModel
    @StateObject private var playerVM = PlayerViewModel()
    
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
            playerVM.playList = playlist
        }
        .onDisappear {
            appModel.vaultManager.clearTmpDirectory()
        }
    }
}
