//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsItemView<T:View> : View {
    
    var imageName : String = ""
    var title : String = ""
    var value : String = ""
    var destination : T?
    var completion : (() -> ())?
    
    var body : some View {
        
        HStack {
            Image(imageName)
            Spacer()
                .frame(width: 10)
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
            
        }.padding(.all, 18)
            .contentShape(Rectangle())
            .if(( destination != nil) , transform: { view in
                view.navigateTo(destination:  destination)
                
            })
                .onTapGesture {
                completion?()
            }
    }
}

struct SettingsItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsItemView<AnyView>(imageName: "settings.timeout",
                                  title: "Test",
                                  value: "Test")
        .background(Styles.Colors.backgroundMain)
    }
}
