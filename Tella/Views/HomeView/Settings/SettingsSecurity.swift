//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsSecurity : View {
    
    @ObservedObject var viewModel: SettingsModel

    var body: some View {
        ZStack {
            Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
            Form {
                Section{
                    SettingToggleItem(title: "Quick Delete", description: "Shows a sliding button on the homescreen to quicky exit Tella in emergency situations. ", toggle: $viewModel.quickDelete)
                    SettingToggleItem(title: "Delete vault", description: "Delete all photos, videos, and audio recordings in your Tella Gallery.", toggle: $viewModel.deleteVault)
                    SettingToggleItem(title: "Delete forms", description: "Delete all draft and submitted forms.", toggle: $viewModel.deleteForms)
                    SettingToggleItem(title: "Delete server settings", description: "Delete your connections to servers and all forms associated with them.", toggle: $viewModel.deleteServerSettings)
                }
                .listRowBackground(Color(Styles.Colors.backgroundTab))
            }.background(Color(Styles.Colors.backgroundMain))
        }
        .navigationBarTitle("Secutiry")
    }
}

struct SettingsSecurity_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsSecurity(viewModel: SettingsModel())
        }
    }
}
