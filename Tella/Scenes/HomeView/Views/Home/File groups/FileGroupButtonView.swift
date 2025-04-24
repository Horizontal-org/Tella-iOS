//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FileGroupView<Destination:View>: View {
    
    let groupName: String
    let iconName: String
    let destination: Destination
    
    var body: some View {
        
        Button {
            navigateTo(destination: destination)
        } label: {
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
            .background(Color.white.opacity(0.16))
            .cornerRadius(10)
        }
    }
}

struct FileGroupView_Previews: PreviewProvider {
    static var previews: some View {
        FileGroupView(groupName: "name", iconName: "files.documents", destination: EmptyView())
            .background(Styles.Colors.backgroundMain)
    }
}

