//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct EditServerDisplayItem: View {
    
    let title: String
    let description: String

    var body: some View {
        HStack {
            
        VStack(alignment: .leading){
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white).padding(.bottom, 2)
                .padding(.bottom, -5)
            
            Text(description)
                .foregroundColor(Color.white)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
        }
            Spacer()
        } .padding(.all, 18)
    }
}

struct EditServerDisplayItem_Previews: PreviewProvider {
    static var previews: some View {
        EditServerDisplayItem(title: "Title", description: "Description").background(Styles.Colors.backgroundMain)
    }
}
