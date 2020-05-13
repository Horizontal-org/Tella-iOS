//
//  PasswordView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 4/22/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This struct represents the view for users to setup a lock for the app. It is shown once on initial app setup.
 */
import SwiftUI

struct PasswordView: View {
    
    let back: () -> ()
    
    var body: some View {
        return VStack {
            bigText("TELLA", true)
            Spacer()
            smallText("Choose lock type:")
            Spacer().frame(height: 30)
            roundedInitPasswordButton("        Password        ", .PASSWORD, self.back)
            Spacer().frame(height: 10)
            roundedInitPasswordButton("  Phone Passcode  ", .PASSCODE, self.back)
            Spacer().frame(height: 10)
            roundedInitPasswordButton(" Phone Biometrics ", .BIOMETRIC, self.back)
            Spacer()
        }
    }
}
