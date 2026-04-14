//
//  AdvancedServerSettingsCardView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/11/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct AdvancedServerSettingsCardView: View {
    
    @StateObject var serverViewModel : TellaWebServerViewModel
    
    var body: some View {
        
        SettingsCardView(cardViewArray: [
            autoUploadView().eraseToAnyView(),
            $serverViewModel.autoUpload.wrappedValue ? autoDeleteView().eraseToAnyView() : nil,
            backgroundUploadView().eraseToAnyView()
            // ShareInfoView(shareInfo: $serverViewModel.activatedMetadata).eraseToAnyView()
        ])
    }
    
    func shareInfoView(shareInfo : Bool) -> some View {
        
        SettingToggleItem(title: LocalizableSettings.shareVerificationTitle.localized,
                          description: LocalizableSettings.shareVerificationExpl.localized,
                          toggle: $serverViewModel.activatedMetadata,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    func backgroundUploadView() -> some View {
        
        SettingToggleItem(title: LocalizableSettings.backgroundUploadTitle.localized,
                          description: LocalizableSettings.backgroundUploadExpl1.localized
                          + "\n\n" + LocalizableSettings.backgroundUploadExpl2.localized,
                          toggle: $serverViewModel.backgroundUpload,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    func autoUploadView() -> some View {
        
        SettingToggleItem(title: LocalizableSettings.autoReportTitle.localized,
                          description: LocalizableSettings.autoReportExpl.localized,
                          toggle: $serverViewModel.autoUpload,
                          isDisabled: serverViewModel.isAutoUploadServerExist,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    
    func autoDeleteView() -> some View {
        
        SettingToggleItem(title: LocalizableSettings.autoDeleteTitle.localized,
                          description: LocalizableSettings.autoDeleteExpl.localized,
                          toggle: $serverViewModel.autoDelete,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
}

#Preview {
    AdvancedServerSettingsCardView(serverViewModel: TellaWebServerViewModel.stub())
}
