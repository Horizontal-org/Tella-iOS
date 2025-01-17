//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

struct MainView: View  {
    
    @State private var showingRecoredrView : Bool = false
    
    @EnvironmentObject private var appModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var sheetManager: SheetManager
    @State private var shouldReload : Bool = false
    
    init(mainAppModel: MainAppModel) {
        UIApplication.shared.setupApperance()
    }
    
    var body: some View {
        ZStack {
            
            contentView
            
            DragView(modalHeight: sheetManager.modalHeight,
                     shouldHideOnTap: sheetManager.shouldHideOnTap,
                     backgroundColor: sheetManager.backgroundColor,
                     isShown: $sheetManager.isPresented) {
                sheetManager.content
            }
            securityScreenView
            
        }
    }
    
    private var contentView: some View {
        
        ZStack {
            CustomNavigation() {
                tabbarContentView
            }.accentColor(.white)
            
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
    
    var tabbarContentView: some View {
        
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
            
            SettingsMainView(appModel: appModel)
                .tabItem {
                    Image("tab.settings")
                    Text(LocalizableSettings.settAppBar.localized)
                }.tag(MainAppModel.Tabs.settings)
        }
    }
    
    @ViewBuilder
    var securityScreenView : some View {
        if appViewState.homeViewModel.shouldShowSecurityScreen == true || appViewState.homeViewModel.shouldShowRecordingSecurityScreen == true ,    appViewState.homeViewModel.settings.screenSecurity == true {
            Color.white
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(mainAppModel: MainAppModel.stub())
            .preferredColorScheme(.light)
            .previewLayout(.device)
            .previewDevice("iPhone 8")
            .environmentObject(MainAppModel.stub())
    }
}

