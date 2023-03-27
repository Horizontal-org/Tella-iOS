//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AdvancedServerSettingsView: View {
    
    @State private var presentingSuccessAdvancedSettings : Bool = false
    @EnvironmentObject var serverVM : ServerViewModel
    
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
                    presentingSuccessAdvancedSettings = true
                }, saveAction: {
                    serverVM.updateServer()
                    presentingSuccessAdvancedSettings = true
                })
            }
            nextViewLink
        }
        .toolbar {
            LeadingTitleToolbar(title: "Advanced settings")
        }
    }
    
    
    private var nextViewLink: some View {
        SuccessAdvancedSettingsView(isPresented: $presentingSuccessAdvancedSettings)
            .addNavigationLink(isActive: $presentingSuccessAdvancedSettings)
    }
    
}

struct AdvancedServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedServerSettingsView()
    }
}



