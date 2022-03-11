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

            Text(emptyListType == .allFiles ? LocalizableHome.emptyAllFilesMessage.localized :  LocalizableHome.emptyFolderMessage.localized)
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
