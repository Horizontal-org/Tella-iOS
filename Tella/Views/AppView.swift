//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    @State private var selection: Tabs = .home
    @EnvironmentObject private var viewModel: SettingsModel

     private enum Tabs: Hashable {
        case home
        case forms
        case reports
        case camera
        case mic
     }
    
    init() {
        setDebugLevel(level: .debug, for: .app)
        setDebugLevel(level: .debug, for: .crypto)
        setupApperance()
    }
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image("tab.home")
                    Text("Home")
                }.tag(Tabs.home)
            CameraView()
                .tabItem {
                    Image("tab.camera")
                    Text("Camera")
            }.tag(Tabs.camera)
            MicView()
                .tabItem {
                    Image("tab.mic")
                    Text("Mic")
                }.tag(Tabs.mic)
            FormsView()
                .tabItem {
                    Image("tab.forms")
                    Text("Forms")
                }
        }
        .accentColor(.white)
    }
    
    private func setupApperance() {
        
        UITableView.appearance().separatorStyle = .none
        UITabBar.appearance().barTintColor = Styles.Colors.backgroundTab
        UINavigationBar.appearance().backgroundColor = Styles.Colors.backgroundMain
        
//        UINavigationBar.appearance().largeTitleTextAttributes = [
//            .foregroundColor: UIColor.white,
//            .backgroundColor: Styles.Colors.backgroundMain,
//            .font: UIFont.boldSystemFont(ofSize: 35)]
//        
//        UINavigationBar.appearance().titleTextAttributes = [
//            .foregroundColor: UIColor.white,
//            .backgroundColor: Styles.Colors.backgroundMain,
//            .font: UIFont.systemFont(ofSize: 18),
//        ]
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = Styles.Colors.backgroundMain
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)],
for: .normal)
        
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .preferredColorScheme(.light)
            .previewLayout(.device)
            .previewDevice("iPhone Xʀ")
    }
}
