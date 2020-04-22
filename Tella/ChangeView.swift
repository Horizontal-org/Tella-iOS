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
            HStack {
                backButton {
                    self.back()
                }
                Spacer()
                mediumText("CHANGE")
                Spacer()
            }
            smallText("Change password to type:")
            Spacer()
            Button(action: {
                do {
                    try CryptoManager.updateKeys(self.privateKey, .PASSWORD)
                } catch {}
                self.back()
            }) {
                smallText("Password")
            }
            Button(action: {
                do {
                    try CryptoManager.updateKeys(self.privateKey, .PASSCODE)
                } catch {}
                self.back()
            }) {
                smallText("Phone Passcode")
            }
            Button(action: {
                do {
                    try CryptoManager.updateKeys(self.privateKey, .BIOMETRIC)
                } catch {}
                self.back()
            }) {
                smallText("Phone Biometrics")
            }
            Spacer()
        }
    }
}
