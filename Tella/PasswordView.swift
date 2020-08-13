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

    static let passwordTypes: [PasswordTypeEnum] = [.PASSWORD, .PASSCODE, .BIOMETRIC]
    
    var body: some View {
        return VStack {
            bigText("TELLA", true)
            Spacer()
            smallText("Choose lock type:")
            Spacer().frame(height: 30)
            VStack {
                ForEach(Array(zip(Self.passwordTypes.indices, Self.passwordTypes)), id: \.0) { index, type in
                    Group {
                        if index > 0 {
                            Spacer().frame(height: 10)
                        }
                        roundedInitPasswordButton(type.buttonText, type) { isSuccess in
                            if isSuccess {
                                self.back()
                            }
                        }
                    }
                }
            }
                .fixedSize()
            Spacer()
        }
    }
}
