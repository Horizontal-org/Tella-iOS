//
//  ChangeView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 4/22/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This struct represents the view presented when users want to change their lock type from the settings page. It differs from the PasswordView struct because it can only be accessed with the user's current lock.
 */

import SwiftUI
import Foundation

struct ChangeView: View {
    
    let back: () -> ()
    let privateKey: SecKey
    
    var body: some View {
        return VStack {
            bigText("TELLA", true)
            Spacer()
            smallText("Change lock type:")
            Spacer().frame(height: 30)
            roundedChangePasswordButton("        Password        ", self.privateKey, .PASSWORD, self.back)
            Spacer().frame(height: 10)
            roundedChangePasswordButton("  Phone Passcode  ", self.privateKey, .PASSCODE, self.back)
            Spacer().frame(height: 10)
            roundedChangePasswordButton(" Phone Biometrics ", self.privateKey, .BIOMETRIC, self.back)
            Spacer()
        }
    }
}
