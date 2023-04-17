//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AdvancedServerSettingsView: View {
    
    @EnvironmentObject var serverVM : ServerViewModel
    @EnvironmentObject var serversVM : ServersViewModel

    var body: some View {
        
        ContainerView {
            VStack {
                
                SettingsCardView(cardViewArray: [/*ShareInfoView(shareInfo: $serverVM.activatedMetadata).eraseToAnyView(),*/
//                    AutoUploadView(autoUpload: $serverVM.autoUpload, isDisabled: serverVM.isAutoUploadServerExist).eraseToAnyView(),
//                    AutoDeleteView(autoDelete: $serverVM.autoDelete).eraseToAnyView(),
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



