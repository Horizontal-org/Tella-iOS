//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    @State private var selection: Tabs = .home

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
        ZStack{
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Image("tab.home")
                        Text("Home")
                            .foregroundColor(.red)
                    }.tag(Tabs.home)
    //            HomeView()
    //                .tabItem {
    //                    Image("tab.forms")
    //                    Text("Forms")
    //            }.tag(Tabs.forms)
    //            UploadView()
    //                .tabItem {
    //                    Image("tab.upload")
    //                    Text("Reports")
    //            }.tag(Tabs.reports)
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
    }
    
    private func setupApperance() {
        UITabBar.appearance().barTintColor = Styles.Colors.backgroundTab
        
        UINavigationBar.appearance().backgroundColor = Styles.Colors.backgroundMain
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .backgroundColor: Styles.Colors.backgroundMain,
            .font: UIFont.boldSystemFont(ofSize: 35)]
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .backgroundColor: Styles.Colors.backgroundMain,
            .font: UIFont.systemFont(ofSize: 18),
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)],
                                                            for: .normal)
        UIWindow.appearance().tintColor = Styles.Colors.backgroundMain
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
