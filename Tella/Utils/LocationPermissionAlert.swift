//
//  LocationPermissionAlert.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

enum LocationPermissionAlert {
    static func denied(onCancel: @escaping () -> Void = {}) -> Alert {
        Alert(title: Text(""),
              message: Text(message),
              primaryButton: .default(
                Text(LocalizableUwazi.uwaziEntityGeolocationDeniedLocationActionCancel.localized),
                action: onCancel
              ),
              secondaryButton: .default(
                Text(LocalizableUwazi.uwaziEntityGeolocationDeniedLocationActionSettings.localized),
                action: {
                    UIApplication.shared.openSettings()
                }
              ))
    }
    
    private static var message: String {
        LocalizableUwazi.uwaziEntityGeolocationDeniedLocationExpl1.localized.addTwolines
        + LocalizableUwazi.uwaziEntityGeolocationDeniedLocationExpl2.localized.addline
        + LocalizableUwazi.uwaziEntityGeolocationDeniedLocationExpl3.localized.numbered(1).addline
        + LocalizableUwazi.uwaziEntityGeolocationDeniedLocationExpl4.localized.numbered(2).addline
        + LocalizableUwazi.uwaziEntityGeolocationDeniedLocationExpl5.localized.numbered(3)
    }
}
