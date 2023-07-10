//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ToastView: View {
    
    @State var isShowingView : Bool = true
    var message : String
    var width = CGFloat.infinity
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: width)
                .background(Color.white)
                .cornerRadius(4)
                .padding()
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView( message: "Message")
    }
}
