//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsAboutHelp : View {
    
    init() {
    }
    
    var body: some View {
        ZStack {
            Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
            VStack {
                Image("tella_Logo")
                    .frame(width: 65, height: 72, alignment: .center)
                    .padding()
                Form {
                    Section{
                        List{
                            SettingItem(name: "Tutorial", image: Image(systemName: "info.circle"))
                            SettingItem(name: "FAQ", image: Image(systemName: "questionmark.circle"))
                            SettingItem(name: "Contact us", image: Image(systemName: "envelope"))
                            SettingItem(name: "Privacy Policy", image: Image(systemName: "shield"))
                        }
                    }
                    .listRowBackground(Color(Styles.Colors.backgroundTab))
                }.background(Color(Styles.Colors.backgroundMain))
            }
        }
        .navigationBarTitle("About&Help")
    }
}

struct SettingsAboutHelp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsAboutHelp()
        }
    }
}

