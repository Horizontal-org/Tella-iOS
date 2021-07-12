//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileDetailView: View {

    var file: VaultFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            switch file.type {
            case .audio:
                WebViewer(url: file.containerName)
            case .document:
                WebViewer(url: file.containerName)
            case .video:
                //need to provide file path with vault
                VideoViewer()
            case .image:
                ImageViewer(imageData: file.thumbnail)
            case .folder:
                ImageViewer(imageData: file.thumbnail)
            default:
                WebViewer(url: file.containerName)
            }
        }
    }
}

struct FileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileDetailView(file: VaultFile.stub(type: .image))
    }
}
