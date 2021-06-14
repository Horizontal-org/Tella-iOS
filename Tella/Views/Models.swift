//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

class MainAppModel: ObservableObject {
    @Published var settings: SettingsModel = SettingsModel()
    @Published var fileManager: VaultManager = VaultManager.shared
}

class SettingsModel: ObservableObject {
    var offLineMode = false
    var quickDelete: Bool = false
    var deleteVault: Bool = false
    var deleteForms: Bool = false
    var deleteServerSettings: Bool = false
}
