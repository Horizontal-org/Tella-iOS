//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsBottomView: View {
  
    var cancelAction : (() -> Void)
    var saveAction : (() -> Void)
    var saveActionTitle = LocalizableSettings.settLockTimeoutSaveSheetAction.localized
    var isDisable: Bool = false

    var body: some View {
        
        HStack(spacing: 16) {
            
            Spacer()
            
            Button {
                cancelAction()
            } label: {
                Text(LocalizableSettings.UwaziLanguageCancel.localized)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .background(Color(UIColor(hexValue: 0xF5F5F5)).opacity(0.16))
                    .cornerRadius(25)
            }
            
            Button {
                saveAction()
            } label: {
                Text(saveActionTitle)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .background(Styles.Colors.yellow)
                    .opacity(isDisable ? 0.8 : 1)
                    .cornerRadius(25)
            }.disabled(isDisable)
            
        }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
      }
}

struct SettingsBottomView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBottomView(cancelAction: {}, saveAction: {})
    }
}
