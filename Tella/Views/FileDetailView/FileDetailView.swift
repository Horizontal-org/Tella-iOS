//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileDetailView: View {

    @ObservedObject var appModel: MainAppModel

    var file: VaultFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch file.type {
            case .audio:
                WebViewer(url: file.containerName)
            case .document:
                WebViewer(url: file.containerName)
            case .video:
                VideoViewer(videoURL: appModel.vaultManager.loadVideo(file: file),
                            appModel: appModel)
            case .image:
                ImageViewer(imageData: appModel.vaultManager.load(file: file))
            case .folder:
                ImageViewer(imageData: file.thumbnail)
            default:
                WebViewer(url: file.containerName)
            }
        }
    }
    
}
