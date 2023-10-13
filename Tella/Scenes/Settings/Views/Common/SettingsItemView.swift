//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsItemView<T:View> : View {
    
    var imageName : String = ""
    var title : String = ""
    var value : String = ""
    var presentationType : ViewPresentationType = .push
    var destination : T?
    var completion : (() -> ())?
    
    var body : some View {
        
        Button {
            if (destination != nil) {
                
                switch presentationType {
                case .push:
                    navigateTo(destination:  destination)
                    
                case .present:
                    self.present(style: .fullScreen, transitionStyle: .crossDissolve) {
                        destination
                    }
                }
            }
            completion?()
        } label: {
            
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
