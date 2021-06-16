//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileDetailView: View {

    var file: VaultFile
    var body: some View {
        VStack(){
            Image(uiImage: file.thumbnailImage)
            Text(file.fileName ?? "N/A")
            Text("\(file.created)")
        }
    }
}

struct FileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileDetailView(file: VaultFile.stub(type: .image))
    }
}
