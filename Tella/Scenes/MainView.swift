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
            securityScreenView
        }.navigationBarHidden(false)
    }
    
    private var tabbar: some View {
        ZStack {
            CustomNavigation() {
                TabView(selection: $appModel.selectedTab) {
                    HomeView(appModel: appModel)
                        .tabItem {
                            Image("tab.home")
                            Text(LocalizableHome.tabBar.localized)
                        }.tag(MainAppModel.Tabs.home)
                    
                    ContainerView{}
                        .tabItem {
                            Image("tab.camera")
                            Text(LocalizableCamera.tabBar.localized)
                        }.tag(MainAppModel.Tabs.camera)
                    
                    ContainerView{}
                        .tabItem {
                            Image("tab.mic")
                            Text(LocalizableRecorder.tabBar.localized)
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
                .navigationBarTitle(LocalizableHome.appBar.localized, displayMode: .inline)
            }
            .accentColor(.white)

            if appModel.selectedTab == .mic {
                RecordView(appModel: appModel,
                           sourceView: .tab,
                           showingRecoredrView: $showingRecoredrView)
            }
            
            if appModel.selectedTab == .camera {
                CameraView(sourceView: .tab,
                           showingCameraView: $appViewState.shouldHidePresentedView,
                           mainAppModel: appModel)
            }
        }
    }
    
    @ViewBuilder
    var securityScreenView : some View {
        if appViewState.homeViewModel.shouldShowSecurityScreen == true || appViewState.homeViewModel.shouldShowRecordingSecurityScreen == true ,    appViewState.homeViewModel.settings.screenSecurity == true {
            Color.white
                .edgesIgnoringSafeArea(.all)
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
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                                      .font: UIFont(name: Styles.Fonts.boldFontName, size: 35)!]
        let image = UIImage(named: "back")
        image?.imageFlippedForRightToLeftLayoutDirection()
        
        coloredAppearance.setBackIndicatorImage(image, transitionMaskImage: image)
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().backgroundColor = Styles.uiColor.backgroundMain
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        
    }
    
    @ViewBuilder
    private var leadingView : some View {
        if appModel.selectedTab == .home {
            Button() {
                navigateTo(destination: SettingsMainView(appModel: appModel))
            } label: {
                Image("home.settings")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
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
            .previewDevice("iPhone 8")
            .environmentObject(MainAppModel.stub())
    }
}
