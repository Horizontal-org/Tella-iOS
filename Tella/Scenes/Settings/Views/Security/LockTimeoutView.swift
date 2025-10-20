//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct LockTimeoutView: View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                BottomSheetTitleView(title: LocalizableSettings.settLockTimeoutSheetTitle.localized,
                          description: LocalizableSettings.settLockTimeoutSheetExpl.localized)
                
                Spacer()
                    .frame(height: 30)
                
                OptionsView()
                
            }
            
            Spacer()
            
            BottomButtonsView(cancelAction: {
                settingsViewModel.cancelLockTimeout()
                sheetManager.hide()
            }, cancelLabel: LocalizableSettings.settLockTimeoutCancelSheetAction.localized, saveAction: {
                settingsViewModel.saveLockTimeout()
                sheetManager.hide()
            }, saveLabel: LocalizableSettings.settLockTimeoutSaveSheetAction.localized)
        }
    }
}

struct OptionsView : View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 30) {
            
            ForEach(settingsViewModel.lockTimeoutOptions, id:\.self) { item in
                
                Button {
                    settingsViewModel.selectedLockTimeoutOption = item.lockTimeoutOption
                } label: {
                    LockTimeoutOptionView(lockTimeoutOption: item)
                }
            }
        }
    }
}

struct LockTimeoutOptionView : View {
    
    @ObservedObject var lockTimeoutOption: LockTimeoutOptionsStatus
    
    var body: some View {
        HStack(spacing: 15) {
            
            lockTimeoutOption.isSelected ? Image("radio_selected") : Image("radio_unselected")
            
            Text(lockTimeoutOption.lockTimeoutOption.displayName)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}


struct LockTimeoutView_Previews: PreviewProvider {
    static var previews: some View {
        LockTimeoutView()
            .background(Styles.Colors.backgroundMain)
    }
}
