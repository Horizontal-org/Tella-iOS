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
            TellaButtonView(title: LocalizableSettings.UwaziLanguageCancel.localized,
                            nextButtonAction: .action,
                            buttonType: .clear,
                            layout: .compact,
                            isValid: .constant(true),
                            action: cancelAction)
            TellaButtonView(title: saveActionTitle,
                            nextButtonAction: .action,
                            buttonType: .yellow,
                            layout: .compact,
                            isValid: .constant(!isDisable),
                            action: saveAction)
        }
        .padding(.horizontal, 16)
      }
}

struct SettingsBottomView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBottomView(cancelAction: {}, saveAction: {})
    }
}
