//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AdvancedServerSettingsView: View {
    
    @State var shareInfo : Bool = false
    @State var backgroundUpload : Bool = false
    @State var presentingSuccessAdvancedSettings : Bool = false
    
    var body: some View {
        
        ContainerView {
            VStack {
                
                Spacer()
                
                Image("settings.verification-info")
                
                Spacer()
                    .frame(height: 16)
                
                Text("Advanced settings")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 16)
                
                SettingsCardView(cardViewArray: [shareInfoView.eraseToAnyView(), backgroundUploadView.eraseToAnyView()])
                
                Spacer()
                
//                BottomLockView(isValid:.constant(true),
//                               nextButtonAction: .destination,
//                               destination: SuccessAdvancedSettingsView())
              
                BottomLockView<AnyView>(isValid:.constant(true),
                                        nextButtonAction: .action,
                                        nextAction:  {
                    presentingSuccessAdvancedSettings = true
                })

                
            }
        }
        .fullScreenCover(isPresented: $presentingSuccessAdvancedSettings) {
            
        } content: {
            SuccessAdvancedSettingsView(isPresented: $presentingSuccessAdvancedSettings)
        }

    }

    var shareInfoView: some View {
        
        SettingToggleItem(title: "Share verification information",
                          description: "Include information about your device and location when sending reports, to make your files verifiable. ",
                          toggle: $shareInfo)
    }

    var backgroundUploadView: some View {
        
        SettingToggleItem(title: "Background upload",
                          description: "Continue uploading reports while doing other tasks or if you exit Tella.\n\nWARNING: If enabled, Tella will remain unlocked until all reports are fully uploaded.",
                          toggle: $backgroundUpload)
    }
}

struct AdvancedServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedServerSettingsView()
    }
}
