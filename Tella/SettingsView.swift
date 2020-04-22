//
//  SettingsView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//


import SwiftUI

struct SettingsView: View {
    
    @State var currentView: SettingsEnum = .MAIN
    
    func settingsBackFunc() {
        self.currentView = .MAIN
    }
        
    let back: Button<AnyView>
    
    func getMainView() -> AnyView {
        return AnyView(Group {
            header(back, "SETTINGS")
            VStack {
                Spacer().frame(maxHeight: 30)
                HStack {
                    smallLabeledImageButton(.KEY, "Change password") {
                        //we want this button to be password protected, so when the button is clicked users have to enter password
                        //present view to enter curr password --> this will need to vary based on what
                        //type of password the user has currently
                        //if right then need to change
                        print("change password button pressed")
                        self.currentView = .CHANGE
                    }
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    smallLabeledImageButton(.KEYTYPE, "Add Biometric") {
                        //present view to enter old password
                        //present new view with options for password types
                        print("change password type button pressed")
                    }
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    // TODO: change image for button
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
        })
    }
    
    func getViewContents(_ currentView: SettingsEnum) -> AnyView {
        switch currentView {
        case .CHANGE:
            guard let privateKey = CryptoManager.recoverKey(.PRIVATE) else {
                return AnyView(
                    VStack {
                        smallText("Correct password not input.")
                        backButton {
                            self.settingsBackFunc()
                        }
                    }
                )
            }
            return AnyView(ChangeView(back: settingsBackFunc, privateKey: privateKey))
        default:
            return getMainView()
        }
    }
    
    var body: some View {
        getViewContents(currentView)
    }
}
