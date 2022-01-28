//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileGroupView: View {

    let groupName: String
    let iconName: String
    
    init(groupName: String, iconName: String) {
        self.groupName = groupName
        self.iconName = iconName
    }
        
    var body: some View {
        ZStack(alignment: .trailing){
            VStack(alignment: .trailing, spacing: 0){
                Text(groupName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .background(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .bottomLeading)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
            }
            VStack(alignment: .trailing, spacing: 0){
                Image(iconName)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
            }
        }
        .frame(height: 80)
        .background(Styles.Colors.backgroundFileButton)
        .cornerRadius(10)
    }
}

struct FileGroupView_Previews: PreviewProvider {
    static var previews: some View {
        FileGroupView(groupName: "name", iconName: "files.documents")
    }
}

