//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    @State private var hideAll = false
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
        
        if hideAll {
            emptyView
        } else {
            tabbar
        }
    }

    private var emptyView: some View{
        VStack{
        }.background(Color(Styles.Colors.backgroundMain))
    }
    
    private var tabbar: some View{
        TabView(selection: $selection) {
            HomeView(viewModel: viewModel, hideAll: $hideAll)
                .tabItem {
                    Image("tab.home")
                    Text("Home")
                }.tag(Tabs.home)
            ReportsView()
            .tabItem {
                Image("tab.reports")
                Text("Reports")
            }.tag(Tabs.camera)
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
        }
        .accentColor(.white)
    }
    
    private func setupApperance() {
        
        UITableView.appearance().separatorStyle = .none
        UITabBar.appearance().barTintColor =  Styles.Colors.backgroundTab
        UINavigationBar.appearance().backgroundColor = Styles.Colors.backgroundMain
        
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
            .environmentObject(SettingsModel())
    }
}
