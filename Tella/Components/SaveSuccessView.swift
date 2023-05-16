//
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SaveSuccessView : View {
    
    var text : String
    @Binding var isPresented : Bool
    
    var body: some View {
        if isPresented {
            VStack {
                Spacer()
                
                Text(text)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(4)
                Spacer()
                    .frame(height: 15)
            }
        }
    }
}

struct SaveSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SaveSuccessView(text: "Test", isPresented: .constant(true))
    }
}
