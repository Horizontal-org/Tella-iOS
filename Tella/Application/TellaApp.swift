//
//  TellaApp.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

@main
struct TellaApp: App {
    
    private var appViewState = AppViewState()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appViewState)
        }
    }
}
