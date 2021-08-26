//
//  SettingsView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This is the Settings page. The button for this is the gear icon in the bottom corner of the main view

 Key functionality:
    User can change their password (actual string) as well as changing what type of password they use (alphanumeric code or 4-digit numeric code)
    User can add a biometric option (TouchID or FaceID depending on the device) which can be used as a shortcut for entering the app. User will still need a fallback password/pin in case biometrics fail (in dark lighting, wearing gloves)
    User can camoflauge the app using the change app icon feature which will present Tella as a blank image for the app icon.
 */

import SwiftUI

struct SettingsView_old: View {
    @EnvironmentObject private var appViewState: AppViewState
    @State var currentView: SettingsEnum = .MAIN
    @State private var shutdownWarningDisplayed = false

    func settingsBackFunc() {
        self.currentView = .MAIN
    }

    private var versionString: String {
        let bundle = Bundle.main
        return "\(bundle.name), \(bundle.versionNumber) (\(bundle.buildNumber))"
    }
    //  Setting up the view for the settings page
    func getMainView() -> some View {
        Group {
            header(
                BackButton {
                    self.appViewState.navigateBack()
                },
                "SETTINGS",
                shutdownWarningPresented: $shutdownWarningDisplayed)
            VStack {
                Spacer().frame(maxHeight: 30)
                HStack {
                    smallLabeledImageButton(.KEY, "Change lock") {
                        self.currentView = .CHANGE
                    }
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    //  change app image
                    smallLabeledImageButton(.GRID, "Change app icon") {
                        if UIApplication.shared.alternateIconName == nil {
                            UIApplication.shared.setAlternateIconName("AppIcon-2")
                        } else {
                            UIApplication.shared.setAlternateIconName(nil)
                        }
                    }
                    Spacer()
                }
                Spacer()
                Text(versionString)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }

    func getViewContents(_ currentView: SettingsEnum) -> some View {
        switch currentView {
        case .CHANGE:
            guard let privateKey = CryptoManagerV1.recoverKey(.PRIVATE) else {
                return VStack {
                    smallText("Correct password not input.")
                    BackButton(action: self.settingsBackFunc)
                }.eraseToAnyView()
            }
            return ChangeView(back: settingsBackFunc, privateKey: privateKey)
                .eraseToAnyView()
        default:
            return getMainView().eraseToAnyView()
        }
    }

    var body: some View {
        getViewContents(currentView)
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SettingsView_old()
        }
    }
}
