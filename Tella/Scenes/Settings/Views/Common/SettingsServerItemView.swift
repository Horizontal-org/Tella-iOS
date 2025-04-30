//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsServerItemView: View {
    
    let title: String?
    var action : (() -> ())?
    
    var body: some View {
        
        HStack{
            VStack(alignment: .leading){
                Text(title ?? "")
                    .foregroundColor(Color.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
            }
            
            Spacer()
            
            Button {
                action?()
            } label: {
                Image("settings.more")
                    .padding()
            } 
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 7))
    }
}

struct SettingsServerItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsServerItemView(title: "CLEEN Foundation")
    }
}
