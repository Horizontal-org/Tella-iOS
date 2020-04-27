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
            Button(action: {
                do {
                    try CryptoManager.initKeys(.PASSWORD)
                    self.back()
                } catch {}
            }) {
                smallText("        Password        ").padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 0.5)
                )
            }
            Spacer().frame(height: 10)
            Button(action: {
                do {
                    try CryptoManager.initKeys(.PASSCODE)
                    self.back()
                } catch {}
            }) {
                smallText("  Phone Passcode  ").padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 0.5)
                )
            }
            Spacer().frame(height: 10)
            Button(action: {
                do {
                    try CryptoManager.initKeys(.BIOMETRIC)
                    self.back()
                } catch {}
            }) {
                smallText(" Phone Biometrics ").padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 0.5)
                )
            }
            Spacer()
        }
    }
}
