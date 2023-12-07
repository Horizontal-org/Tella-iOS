//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoViewer: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject private var playerVM : PlayerViewModel
    
    init(appModel: MainAppModel, currentFile : VaultFileDB, playList: [VaultFileDB?]) {
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
        .toolbar {
            LeadingTitleToolbar(title: playerVM.currentFile?.name ?? "")
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
