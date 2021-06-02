//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsDocumentation : View {
    
    init() {
    }
    
    var body: some View {
        ZStack {
            Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
            Form {
                Section{
                }
                .listRowBackground(Color(Styles.Colors.backgroundTab))
                Section {
                }
            }.background(Color(Styles.Colors.backgroundMain))
        }
        .navigationBarTitle("Documentation")
    }
}

