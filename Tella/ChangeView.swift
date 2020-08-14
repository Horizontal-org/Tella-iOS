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

    @State private var isAlertVisible = false
    
    var body: some View {
        VStack {
            header(backButton { self.back() })
            bigText("TELLA", true)
            Spacer()
            smallText("Change lock type:")
            Spacer().frame(height: 30)

            VStack {
                ForEach(Array(zip(PasswordTypeEnum.allCases.indices, PasswordTypeEnum.allCases)), id: \.0) { index, type in
                    Group {
                        if index > 0 {
                            Spacer().frame(height: 10)
                        }
                        roundedChangePasswordButton(type.buttonText, self.privateKey, type) { isSuccess in
                            if isSuccess {
                                self.back()
                            } else {
                                self.isAlertVisible = true
                            }
                        }
                    }
                }
            }
                .fixedSize()
            Spacer()
        }
        .alert(isPresented: $isAlertVisible) {
            Alert(title: Text("Failed to change lock"))
        }
    }
}
