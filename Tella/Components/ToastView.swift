//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ToastView: View {
    var message: String
    @State private var isShowing = true

    var body: some View {
        ZStack {
            if isShowing {
                Text(message)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(4)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
        .padding()
    }
}
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Styles.Colors.backgroundMain
            ToastView( message: "Message")
        }
    }
}
