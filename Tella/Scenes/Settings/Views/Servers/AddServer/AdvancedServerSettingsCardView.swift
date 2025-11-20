//
//  AdvancedServerSettingsCardView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/11/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
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
        
        SettingToggleItem(title: "Share verification information",
                          description: "Include information about your device and location when sending reports, to make your files verifiable. ",
                          toggle: $serverViewModel.activatedMetadata,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    func backgroundUploadView() -> some View {
        
        SettingToggleItem(title: "Background upload",
                          description: "Continue uploading reports while doing other tasks or if you exit Tella.\n\nWARNING: If enabled, Tella will remain unlocked until all reports are fully uploaded.",
                          toggle: $serverViewModel.backgroundUpload,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    func autoUploadView() -> some View {
        
        SettingToggleItem(title: "Auto-report",
                          description: "Whenever you take a photo/video/audio recording in Tella, a report will automatically be created with the file and uploaded to this project.",
                          toggle: $serverViewModel.autoUpload,
                          isDisabled: serverViewModel.isAutoUploadServerExist,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
    
    
    func autoDeleteView() -> some View {
        
        SettingToggleItem(title: "Auto-delete",
                          description: "Automatically delete files from your device once they are uploaded to this project as a report.",
                          toggle: $serverViewModel.autoDelete,
                          onChange: {
            serverViewModel.mainAppModel.saveSettings()
        })
    }
}

#Preview {
    AdvancedServerSettingsCardView(serverViewModel: TellaWebServerViewModel.stub())
}
