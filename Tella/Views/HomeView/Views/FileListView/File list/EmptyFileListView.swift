//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

enum EmptyListType {
    case allFiles
    case folder
}

struct EmptyFileListView: View {
    
    var emptyListType : EmptyListType

    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image("files.empty-list")
            
            Spacer()
                .frame(height: 20)
            
            Text("You don’t have any files in Tella yet.\n\nTap the “+” button below to import your first file, or go to the Camera or Recorder to create one. You can also create folders to keep your files organized.")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
        
    }
}

struct EmptyFileListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyFileListView(emptyListType: .allFiles)
    }
}
