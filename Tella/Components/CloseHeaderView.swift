//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CloseHeaderView: View {
    
    var title : String = ""
    var isPresented : Binding<Bool> = .constant(false)
    var didClose : (() -> Void)?
    
    var body: some View {
 
            HStack {
                Button {
                    UIApplication.shared.endEditing()
                    didClose?()
                } label: {
                    Image("close")
                }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                
                Text(title)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 20))
                    .foregroundColor(Color.white)
                
                Spacer()
                
            }.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
    }
}

#Preview {
    CloseHeaderView( title: "Test", isPresented: .constant(false))
        .background(Styles.Colors.backgroundMain)
}
