//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    @State private var hideAll = false
    @State private var hideTabBar = false
    @EnvironmentObject private var appModel: MainAppModel

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
        }.background(Styles.Colors.backgroundMain)
    }
    
    private var tabbar: some View{
        TabView(selection: $appModel.selectedTab) {
            HomeView(appModel: appModel, hideAll: $hideAll)
                .tabItem {
                    Image("tab.home")
                    Text("Home")
                }.tag(MainAppModel.Tabs.home)
            ReportsView()
                .tabItem {
                    Image("tab.reports")
                    Text("Reports")
                }.tag(MainAppModel.Tabs.reports)
            CameraView(appModel: appModel)
                .tabItem {
                    Image("tab.camera")
                    Text("Camera")
                }.tag(MainAppModel.Tabs.camera)
            MicView()
                .tabItem {
                    Image("tab.mic")
                    Text("Mic")
                }.tag(MainAppModel.Tabs.mic)
        }
        .accentColor(.white)
    }
    
    private func setupApperance() {
        
        UITableView.appearance().separatorStyle = .none
        UITabBar.appearance().barTintColor =  Styles.uiColor.backgroundTab
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UINavigationBar.appearance().backgroundColor = Styles.uiColor.backgroundMain
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = Styles.uiColor.backgroundMain
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .preferredColorScheme(.light)
            .previewLayout(.device)
            .previewDevice("iPhone Xʀ")
            .environmentObject(MainAppModel())
    }
}
