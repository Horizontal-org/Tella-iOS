//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AppView: View  {
    
    @State private var hideAll = false
    @State private var hideTabBar = false
    @EnvironmentObject private var appModel: MainAppModel
    
    @State private var inputImage: UIImage?
    
    @State private var showingRecoredrView : Bool = false
    
    init() {
        setDebugLevel(level: .debug, for: .app)
        setDebugLevel(level: .debug, for: .crypto)
        setupApperance()
    }
    
    var body: some View {
        if hideAll {
            emptyView
        } else {
            ZStack {
                tabbar
            }
            
        }
    }
    
    private var emptyView: some View{
        VStack{
        }.background(Styles.Colors.backgroundMain)
    }
    
    private var tabbar: some View{
        NavigationView {
            ZStack {
                
                TabView(selection: $appModel.selectedTab) {
                    HomeView(hideAll: $hideAll)
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
                    ContainerView{}
                    .tabItem {
                        Image("tab.camera")
                        Text("Camera")
                    }.tag(MainAppModel.Tabs.camera)
                    
                    ContainerView{}
                    .tabItem {
                        Image("tab.mic")
                        Text("Rec")
                    }.tag(MainAppModel.Tabs.mic)
                }
                
                if appModel.selectedTab == .mic   {
                    RecordView( showingRecoredrView: $showingRecoredrView)
                }
                
                if appModel.selectedTab == .camera   {
                    CameraView(cameraViewModel: CameraViewModel(mainAppModel: appModel))
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingView
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingView
                }
            }
            
        }
        .navigationViewStyle(.stack)
        
        
        .accentColor(.white)
        
        
        .navigationBarTitle("Tella", displayMode: .inline)
        .navigationBarHidden(appModel.selectedTab == .home ? false : true)
        
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
            }
        }
    }
    
    @ViewBuilder
    private var trailingView : some View {
        
        if appModel.selectedTab == .home {
            Button {
                hideAll = true
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
        AppView()
            .preferredColorScheme(.light)
            .previewLayout(.device)
            .previewDevice("iPhone Xʀ")
            .environmentObject(MainAppModel())
    }
}
