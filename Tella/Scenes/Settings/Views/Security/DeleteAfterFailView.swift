//
//  DeleteAfterFailView.swift
//  Tella
//
//  Created by Gustavo on 10/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DeleteAfterFailView: View {
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                BottomSheetTitleView(title: "Delete after failed unlock",
                          description: "Decide how many failed unlock attempts are allowed before everything inside Tella is deleted.")
                
                Spacer()
                    .frame(height: 30)
                
                DeleteOptionsView()
                
            }.padding(EdgeInsets(top: 21, leading: 24, bottom: 0, trailing: 24))
            
            Spacer()
            
            BottomButtonsView(cancelAction: {
                settingsViewModel.cancelDeleteAfterFail()
                sheetManager.hide()
            }, cancelLabel: LocalizableSettings.settLockTimeoutCancelSheetAction.localized, saveAction: {
                settingsViewModel.saveDeleteAfterFail()
                sheetManager.hide()
            }, saveLabel: LocalizableSettings.settLockTimeoutSaveSheetAction.localized)
        }
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
