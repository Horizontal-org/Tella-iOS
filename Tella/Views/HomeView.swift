//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct HomeView: View {

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0){
                    ScrollView{
                        ReventFilesListView()
                        FileGroupsView()
                    }
                }
                AddButtonView()
            }
            .navigationBarTitle("Tella")
            .navigationBarItems(trailing:
                    HStack(spacing: 8) {
                        NavigationLink(destination: SettingsView()) {
                            Image("home.close")
                                .imageScale(.large)
                            }
                        NavigationLink(destination: SettingsView()) {
                            Image("home.settings")
                                .imageScale(.large)
                            }
                    }.background(Color(Styles.Colors.backgroundMain))
                )
            .background(Color(Styles.Colors.backgroundMain))
//            .edgesIgnoringSafeArea(.vertical)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
