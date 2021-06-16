//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

class MainAppModel: ObservableObject {
    
    enum Tabs: Hashable {
       case home
       case forms
       case reports
       case camera
       case mic
    }
    
    @Published var settings: SettingsModel = SettingsModel()
    @Published var fileManager: VaultManager = VaultManager.shared
    @Published var selectedTab: Tabs = .home
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
}

class SettingsModel: ObservableObject {
    var offLineMode = false
    var quickDelete: Bool = false
    var deleteVault: Bool = false
    var deleteForms: Bool = false
    var deleteServerSettings: Bool = false
}
