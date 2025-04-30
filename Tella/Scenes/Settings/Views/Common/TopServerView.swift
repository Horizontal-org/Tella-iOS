//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TopServerView : View {
    
    var title : String
    
    var body: some View {
        
        Image("settings.server")
        
        Spacer()
            .frame(height: 24)
        
        Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
}

struct TopServerView_Previews: PreviewProvider {
    static var previews: some View {
        TopServerView(title: "Test")
    }
}
