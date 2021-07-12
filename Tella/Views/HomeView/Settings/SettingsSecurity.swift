//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsSecurity : View {
    
    @ObservedObject var viewModel: SettingsModel

    var body: some View {
        ZStack {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            Form {
                Section{
                    SettingToggleItem(title: "Quick Delete", description: "Shows a sliding button on the homescreen to quicky exit Tella in emergency situations. ", toggle: $viewModel.quickDelete)
                    SettingToggleItem(title: "Delete vault", description: "Delete all photos, videos, and audio recordings in your Tella Gallery.", toggle: $viewModel.deleteVault)
                    SettingToggleItem(title: "Delete forms", description: "Delete all draft and submitted forms.", toggle: $viewModel.deleteForms)
                    SettingToggleItem(title: "Delete server settings", description: "Delete your connections to servers and all forms associated with them.", toggle: $viewModel.deleteServerSettings)
                    HStack{
                        Button {
                            swapAppIcon()
                        } label: {
                            Text("Change Icon")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white).padding(.bottom, -5)
                        }
                    }
                    .padding()
                }
                .listRowBackground(Styles.Colors.backgroundTab)
            }.background(Styles.Colors.backgroundMain)
        }
        .navigationBarTitle("Secutiry")
    }
    
    private func swapAppIcon() {
        if UIApplication.shared.alternateIconName == nil {
            UIApplication.shared.setAlternateIconName("AppIcon-2")
        } else {
            UIApplication.shared.setAlternateIconName(nil)
        }
    }
    
}

struct SettingsSecurity_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsSecurity(viewModel: SettingsModel())
        }
    }
}
