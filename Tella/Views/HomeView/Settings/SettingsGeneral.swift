//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsGeneral : View {
    
    var body: some View {
        ZStack {
            Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
            Form {
                Section{
                    List{
                    }
                }
                .listRowBackground(Color(Styles.Colors.backgroundTab))
            }.background(Color(Styles.Colors.backgroundMain))
        }
        .navigationBarTitle("General")
    }
}

struct SettingsGeneral_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsGeneral()
        }
    }
}
