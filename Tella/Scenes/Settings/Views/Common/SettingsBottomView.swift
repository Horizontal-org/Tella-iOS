//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsBottomView: View {
  
    var cancelAction : (() -> Void)
    var saveAction : (() -> Void)

    var body: some View {
        
        HStack(spacing: 16) {
            
            Spacer()
            
            Button {
                cancelAction()
            } label: {
                Text("CANCEL")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .background(Color(UIColor(hexValue: 0xF5F5F5)).opacity(0.16))
                    .cornerRadius(25)
            }
            
            Button {
                saveAction()
            } label: {
                Text("SAVE")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .background(Styles.Colors.yellow)
                    .cornerRadius(25)
                
            }
            
        }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
      }
}

struct SettingsBottomView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBottomView(cancelAction: {}, saveAction: {})
    }
}
