//
//  SettingsView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This is the Settings page. The button for this is the gear icon in the bottom corner of the main view
 
 Key functionality:
    User can change their password (actual string) as well as changing what type of password they use (alphanumeric code or 4-digit numeric code)
    User can add a biometric option (TouchID or FaceID depending on the device) which can be used as a shortcut for entering the app. User will still need a fallback password/pin in case biometrics fail (in dark lighting, wearing gloves)
    User can camoflauge the app using the change app icon feature which will present Tella as a blank image for the app icon.
 */
import SwiftUI

struct SettingsView: View {
    
    let back: Button<AnyView>
    
//  Setting up the view for the settings page
    var body: some View {
        return Group {
            header(back, "SETTINGS")
            VStack {
                Spacer().frame(maxHeight: 30)
                HStack {
                    smallLabeledImageButton(.KEY, "Change password") {
                        print("change password button pressed")
                    }
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    smallLabeledImageButton(.KEYTYPE, "Change password type") {
                        print("change password type button pressed")
                    }
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    //  change app image
                    smallLabeledImageButton(.GRID, "Change app icon") {
                        if UIApplication.shared.alternateIconName == nil {
                            UIApplication.shared.setAlternateIconName("AppIcon-2")
                        } else {
                            UIApplication.shared.setAlternateIconName(nil)
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
