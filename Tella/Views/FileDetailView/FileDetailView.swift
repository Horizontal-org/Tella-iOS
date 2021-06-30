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
                ImageViewer(imageData: file.thumbnail)
            case .document:
                PDFKitView(data: file.thumbnail ?? Data())
            case .video:
                ImageViewer(imageData: file.thumbnail)
            case .image:
                ImageViewer(imageData: file.thumbnail)
            case .folder:
                ImageViewer(imageData: file.thumbnail)
            }
        }
    }
}

struct FileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileDetailView(file: VaultFile.stub(type: .image))
    }
}
