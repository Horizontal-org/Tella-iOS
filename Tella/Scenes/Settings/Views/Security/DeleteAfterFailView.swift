//
//  DeleteAfterFailView.swift
//  Tella
//
//  Created by Gustavo on 10/07/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct DeleteAfterFailView: View {
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                BottomSheetTitleView(title: LocalizableSettings.settDeleteAfterFailSheetTitle.localized,
                                     description:LocalizableSettings.settDeleteAfterFailSheetExpl.localized)
                
                Spacer()
                    .frame(height: 30)
                
                DeleteOptionsView()
                
            }.padding(EdgeInsets(top: 21, leading: 24, bottom: 0, trailing: 24))
            
            Spacer()
            bottomButtonsView
        }
    }
    
    var bottomButtonsView : some View {
        BottomButtonsView(cancelAction: {
            settingsViewModel.cancelDeleteAfterFail()
            sheetManager.hide()
        }, cancelLabel: LocalizableSettings.settLockTimeoutCancelSheetAction.localized, saveAction: {
            settingsViewModel.saveDeleteAfterFail()
            sheetManager.hide()
            
            displayDeleteAfterFailToast()
        }, saveLabel: LocalizableSettings.settLockTimeoutSaveSheetAction.localized)
    }
    
    func displayDeleteAfterFailToast () {
        let message: String
        if settingsViewModel.selectedDeleteAfterFailOption == .off {
            message = LocalizableSettings.settDeleteAfterFailOffToast.localized
        } else {
            message = String(format: LocalizableSettings.settDeleteAfterFailToast.localized, settingsViewModel.selectedDeleteAfterFailOption.numberOfAttempts)
        }
        
        Toast.displayToast(message: message)
    }
}

struct DeleteOptionsView : View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 30) {
            
            ForEach(settingsViewModel.deleteAfterFailOptions, id:\.self) { item in
                
                Button {
                    settingsViewModel.selectedDeleteAfterFailOption = item.deleteAfterFailOption
                } label: {
                    DeleteAfterFailOptionView(deleteAfterFailOption: item)
                }
            }
        }
    }
}

struct DeleteAfterFailOptionView : View {
    
    @ObservedObject var deleteAfterFailOption: DeleteAfterFailedOptionsStatus
    
    var body: some View {
        HStack(spacing: 15) {
            
            deleteAfterFailOption.isSelected ? Image("radio_selected") : Image("radio_unselected")
            
            Text(deleteAfterFailOption.deleteAfterFailOption.displayName)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}

struct DeleteAfterFailView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAfterFailView()
    }
}
