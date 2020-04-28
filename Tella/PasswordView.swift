//
//  PasswordView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 4/22/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct PasswordView: View {
    
    let back: () -> ()
    
    var body: some View {
        return VStack {
            bigText("TELLA")
            Spacer()
            smallText("Choose password type:")
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
