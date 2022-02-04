//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @ObservedObject var appModel: MainAppModel
    
    var file: VaultFile
    var videoFilesArray: [VaultFile]?
    var fileType : FileType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch file.type {
                
            case .audio:
                AudioPlayerView(audioData: appModel.vaultManager.load(file: file))
                
            case .document:
                if let file = appModel.vaultManager.loadVideo(file: file) {
                    QuickLookView(file: file)
                }
            case .video:
                if let videoFilesArray = videoFilesArray   {
                    VideoViewer(appModel: appModel, currentFile: file, playlist: videoFilesArray)
                }
            case .image:
                ImageViewer(imageData: appModel.vaultManager.load(file: file))
            case .folder:
                FileListView(appModel: appModel,
                             files: file.files,
                             fileType: fileType,
                             rootFile: file,
                             title: file.fileName)
            default:
                WebViewer(url: file.containerName)
            }
        }
    }
    
}
