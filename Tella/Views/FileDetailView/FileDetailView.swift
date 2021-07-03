//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileDetailView: View {

    var file: VaultFile
    var body: some View {
        VStack(alignment: .center, spacing: 20){
            Image(uiImage: file.thumbnailImage)
                .border(Color.green, width: 1)
                .frame(width: 100, height: 100, alignment: .center)
            Text(file.type.rawValue)
            Text(file.fileName)
            Text(file.containerName)
            Text("\(file.created)")
        }
    }
}

struct FileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileDetailView(file: VaultFile.stub(type: .image))
    }
}
