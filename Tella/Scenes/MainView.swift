//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct MainView: View  {
    
    @State private var showingRecoredrView : Bool = false
    
    @EnvironmentObject private var appModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var sheetManager: SheetManager

 
    init() {
        setDebugLevel(level: .debug, for: .app)
        setDebugLevel(level: .debug, for: .crypto)
        setupApperance()
    }
    
    var body: some View {
        ZStack {
            tabbar
            
            DragView(modalHeight: sheetManager.modalHeight,
                     shouldHideOnTap: sheetManager.shouldHideOnTap,
                     backgroundColor: sheetManager.backgroundColor,
                     isShown: $sheetManager.isPresented) {
                sheetManager.content
            }
        }
    }
    
    private var emptyView: some View {
        VStack{
        }.background(Styles.Colors.backgroundMain)
    }
    
    private var tabbar: some View{
        
        ZStack {
            
            NavigationView {
                
                TabView(selection: $appModel.selectedTab) {
                    HomeView(appModel: appModel)
                        .tabItem {
                            Image("tab.home")
                            Text(Localizable.Home.tabBar)
                        }.tag(MainAppModel.Tabs.home)
/*#if DEBUG
                    ReportsView()
                        .tabItem {
                            Image("tab.reports")
                            Text(Localizable.Reports.tabBarTitle)
                        }.tag(MainAppModel.Tabs.reports)
                    FormsView()
                        .tabItem {
                            Image("tab.forms")
                            Text(Localizable.Forms.tabBarTitle)
                        }.tag(MainAppModel.Tabs.forms)
#endif*/
                    ContainerView{}
                        .tabItem {
                            Image("tab.camera")
                            Text(Localizable.Camera.tabBar)
                        }.tag(MainAppModel.Tabs.camera)
                    
                    ContainerView{}
                        .tabItem {
                            Image("tab.mic")
                            Text(Localizable.Recorder.tabBar)
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
                .navigationBarTitle(Localizable.Home.appBar, displayMode: .inline)
                .navigationBarHidden(appModel.selectedTab == .home ? false : true)
            }
            .accentColor(.white)
            .navigationViewStyle(.stack)
            
            if appModel.selectedTab == .mic   {
                RecordView(appModel: appModel,
                           rootFile: appModel.vaultManager.root,
                           sourceView: .tab,
                           showingRecoredrView: $showingRecoredrView)
            }
            
            if appModel.selectedTab == .camera {
                CameraView(sourceView: .tab,
                           showingCameraView: .constant(false),
                           cameraViewModel: CameraViewModel(mainAppModel: appModel,
                                                            rootFile: appModel.vaultManager.root))
            }
        }
    }
    
    private func setupApperance() {
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.38)
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = Styles.uiColor.backgroundTab
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = Styles.uiColor.backgroundMain
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                 .font: UIFont(name: Styles.Fonts.boldFontName, size: 24)!]
        coloredAppearance.setBackIndicatorImage(UIImage(named: "back"), transitionMaskImage: UIImage(named: "back"))
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().backgroundColor = Styles.uiColor.backgroundMain
    }
    
    @ViewBuilder
    private var leadingView : some View {
        if appModel.selectedTab == .home {
            Button() {
                
            } label: {
                Image("home.settings")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .navigateTo(destination: SettingsMainView(appModel: appModel))
            }.navigateTo(destination: SettingsMainView(appModel: appModel))
        }
    }
    
    @ViewBuilder
    private var trailingView : some View {
        
        if appModel.selectedTab == .home {
            Button {
                appViewState.resetToUnlock()
            } label: {
                Image("home.close")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.light)
            .previewLayout(.device)
            .previewDevice("iPhone Xʀ")
            .environmentObject(MainAppModel())
    }
}
