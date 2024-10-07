//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AdvancedServerSettingsView: View {
    
    @EnvironmentObject var serverVM : TellaWebServerViewModel
    @EnvironmentObject var serversVM : ServersViewModel

    var body: some View {
        
        ContainerView {
            VStack {
                
                SettingsCardView(cardViewArray: [/*ShareInfoView(shareInfo: $serverVM.activatedMetadata).eraseToAnyView(),*/
                    AutoUploadView(autoUpload: $serverVM.autoUpload, isDisabled: serverVM.isAutoUploadServerExist).eraseToAnyView(),
                    $serverVM.autoUpload.wrappedValue ? AutoDeleteView(autoDelete: $serverVM.autoDelete).eraseToAnyView() : nil,
                    BackgroundUploadView(backgroundUpload: $serverVM.backgroundUpload).eraseToAnyView()
                                                ])
                
                Spacer()
                
                SettingsBottomView(cancelAction: {
                    navigateTo(destination: successAdvancedSettingsView)
                }, saveAction: {
                    serverVM.updateServer()
                    navigateTo(destination: successAdvancedSettingsView)

                })
            }
             
        }
        .toolbar {
            LeadingTitleToolbar(title: "Advanced settings")
        }
    }

    private var successAdvancedSettingsView: some View {
        SuccessAdvancedSettingsView()
    }

    
}

struct AdvancedServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedServerSettingsView()
    }
}



