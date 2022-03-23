//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @ObservedObject var appModel: MainAppModel
    
    
    var file: VaultFile
    var videoFilesArray: [VaultFile]?
    var fileType : [FileType]?
    
    var body: some View {
        switch file.type {
            
        case .audio:
            AudioPlayerView(vaultFile: file)
            
        case .document:
            if let file = appModel.vaultManager.loadVideo(file: file) {
                QuickLookView(file: file)
            }
            
        case .video:
            VideoViewer(appModel: appModel, currentFile: file, playlist: videoFilesArray ?? [file] )
            
        case .image:
            ImageViewer(imageData: appModel.vaultManager.load(file: file))
            
        case .folder:
            EmptyView()
            
        default:
            WebViewer(url: file.containerName)
        }
    }
}
