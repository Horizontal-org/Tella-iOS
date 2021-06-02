//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: SettingsModel
    
    init(viewModel: SettingsModel) {
        self.viewModel = viewModel
        setupView()
    }
    
    private func setupView() {
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(spacing: 0){
                    ScrollView{
                        ReventFilesListView()
                        FileGroupsView()
                    }
                }
                buttonView
            }
            .navigationBarTitle("Tella")
            .navigationBarItems(trailing:
                    HStack(spacing: 8) {
                        Image("home.close")
                            .imageScale(.large)
                        NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                            Image("home.settings")
                                .imageScale(.large)
                            }
                    }.background(Color(Styles.Colors.backgroundMain))
                )
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
    
    var buttonView: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    //TODO: add new media action
                }) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 50, height: 50, alignment: .center)
                        .overlay(Image("home.add"))
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: SettingsModel())
    }
}
