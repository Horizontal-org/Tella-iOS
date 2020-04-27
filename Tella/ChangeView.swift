//
//  ChangeView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 4/22/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import Foundation

struct ChangeView: View {
    
    let back: () -> ()
    let privateKey: SecKey
    
    var body: some View {
        return VStack {
            bigText("TELLA")
            Spacer()
            smallText("Change password type:")
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
