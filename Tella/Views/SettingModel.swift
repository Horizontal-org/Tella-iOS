//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

class SettingsModel: ObservableObject {
    @Published var offLineMode = false
    @Published var quickDelete: Bool = false
    @Published var deleteVault: Bool = false
    @Published var deleteForms: Bool = false
    @Published var deleteServerSettings: Bool = false
}
