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
            mediumText("SECURITY")
            smallText("Choose password type:")
            Spacer()
            Button(action: {
                do {
                    try CryptoManager.initKeys(.PASSWORD)
                    self.back()
                } catch {}
            }) {
                smallText("Password")
            }
            Button(action: {
                do {
                    try CryptoManager.initKeys(.PASSCODE)
                    self.back()
                } catch {}
            }) {
                smallText("Phone Passcode")
            }
            Button(action: {
                do {
                    try CryptoManager.initKeys(.BIOMETRIC)
                    self.back()
                } catch {}
            }) {
                smallText("Phone Biometrics")
            }
            Spacer()
        }
    }
}
