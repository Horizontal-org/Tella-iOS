//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @ObservedObject var appModel: MainAppModel
    
    var file: VaultFile
    var fileType : FileType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch file.type {
            case .audio:
                WebViewer(url: file.containerName)
            case .document:
                if let file = appModel.vaultManager.loadVideo(file: file) {
                    QuickLookView(file: file)
                }
            case .video:
                VideoViewer(videoURL: appModel.vaultManager.loadVideo(file: file),
                            appModel: appModel)
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
