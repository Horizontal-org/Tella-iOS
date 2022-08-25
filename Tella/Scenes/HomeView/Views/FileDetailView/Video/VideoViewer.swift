//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject private var playerVM : PlayerViewModel
    
    init(appModel: MainAppModel, currentFile : VaultFile, playList: [VaultFile?]) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(appModel: appModel,
                                                              currentFile: currentFile,
                                                              playList: playList))
    }
    
    var body: some View {
        VStack {
            CustomVideoPlayer(playerVM: playerVM)
                .overlay(CustomVideoControlsView(playerVM: playerVM)
                         ,alignment: .bottom)
        }
        .onDisappear {
            appModel.vaultManager.clearTmpDirectory()
        }
        .toolbar {
            LeadingTitleToolbar(title: playerVM.currentFile?.fileName ?? "")
            fileActionTrailingView()
        }
        .ignoresSafeArea()
    }
    
    func fileActionTrailingView() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            MoreFileActionButton(file: playerVM.currentFile, moreButtonType: .navigationBar)
        }
    }
    
}
