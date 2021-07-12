//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsDocumentation : View {
    
    init() {
    }
    
    var body: some View {
        ZStack {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            Form {
                Section{
                }
                .listRowBackground(Styles.Colors.backgroundTab)
                Section {
                }
            }.background(Styles.Colors.backgroundMain)
        }
        .navigationBarTitle("Documentation")
    }
}

