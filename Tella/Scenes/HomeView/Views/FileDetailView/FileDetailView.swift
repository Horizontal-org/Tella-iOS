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
                .toolbar {
                    LeadingTitleToolbar(title: file.fileName)
                }
            
        case .document:
            if let file = appModel.vaultManager.loadVideo(file: file) {
                QuickLookView(file: file)
                    .toolbar {
                        LeadingTitleToolbar(title: self.file.fileName)
                    }
            }
            
        case .video:
            VideoViewer(appModel: appModel, currentFile: file, playlist: videoFilesArray ?? [file] )
                .toolbar {
                    LeadingTitleToolbar(title: file.fileName)
                }
        case .image:
            ImageViewer(imageData: appModel.vaultManager.load(file: file))
                .toolbar {
                    LeadingTitleToolbar(title: file.fileName)
                }
        case .folder:
            EmptyView()
            
        default:
            WebViewer(url: file.containerName)
        }
            

    }
}
