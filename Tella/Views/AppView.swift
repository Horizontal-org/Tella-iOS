//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    @State private var hideAll = false
    @State private var hideTabBar = false
    @EnvironmentObject private var appModel: MainAppModel
    
    @State private var inputImage: UIImage?
    
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
        NavigationView {
            TabView(selection: $appModel.selectedTab) {
                HomeView(appModel: appModel, hideAll: $hideAll)
                    .tabItem {
                        Image("tab.home")
                        Text("Home")
                    }.tag(MainAppModel.Tabs.home)
#if DEBUG
                ReportsView()
                    .tabItem {
                        Image("tab.reports")
                        Text("Reports")
                    }.tag(MainAppModel.Tabs.reports)
                FormsView()
                    .tabItem {
                        Image("tab.forms")
                        Text("Forms")
                    }.tag(MainAppModel.Tabs.forms)
#endif
                CustomCameraView(completion: { image in
                    if let image = image {
                        self.appModel.add(image: image, to: appModel.vaultManager.root, type: .image)
                    }
                })
                    .tabItem {
                        Image("tab.camera")
                        Text("Camera")
                    }.tag(MainAppModel.Tabs.camera)
                AudioRecordView()
                    .tabItem {
                        Image("tab.mic")
                        Text("Mic")
                    }.tag(MainAppModel.Tabs.mic)
            }
            
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingView
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingView
                }
            }
            
            
//            .navigationBarItems(
//                leading:
//                    leadingView
//                , trailing:
//                    trailingView
//            )
        }.navigationViewStyle(.stack)
        
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
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                 .font: UIFont(name: Styles.Fonts.boldFontName, size: 24)!]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                                      .font: UIFont(name: Styles.Fonts.boldFontName, size: 24)!]
        coloredAppearance.setBackIndicatorImage(UIImage(named: "back"), transitionMaskImage: UIImage(named: "back"))
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        
    }
    
    @ViewBuilder
    private var leadingView : some View {
        
        if appModel.selectedTab == .home {
            Image("home.settings")
                .frame(width: 19, height: 20)
                .aspectRatio(contentMode: .fit)
                .navigateTo(destination: SettingsView(appModel: appModel))
        }
    }
    
    @ViewBuilder
    private var trailingView : some View {
        
        if appModel.selectedTab == .home {
            Button {
                hideAll = true
            } label: {
                Image("home.close")
                    .imageScale(.large)
            }
        }
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
