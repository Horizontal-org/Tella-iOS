//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ToastView: View {
    var message: String
    @State private var isShowing = true
    
    var body: some View {
        ZStack {
            if isShowing && !message.isEmpty {
                HStack(alignment: .center) {
                    textView
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(4)
            }
        }
        .padding(16)
    }
    
    var textView : some View {
        Text(message)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(.black)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
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
