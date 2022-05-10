//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TopCalculatorMessageView :  View {
    
    var text : String
    
    var body: some View {
        Text(text)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 16, leading: 40, bottom: 16, trailing: 40))
            .background(Styles.Colors.mint)
            .cornerRadius(16)
    }
}

struct TopCalculatorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        TopCalculatorMessageView(text: "Text")
    }
}
