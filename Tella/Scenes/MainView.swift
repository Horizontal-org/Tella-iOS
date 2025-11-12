//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine

struct MainView: View  {

    @ObservedObject var mainAppModel: MainAppModel
    @ObservedObject var appViewState: AppViewState
    @EnvironmentObject private var sheetManager: SheetManager
    @State private var shouldReload : Bool = false
   
    var homeViewModel: HomeViewModel
    var settingsViewModel: SettingsViewModel
    var serversViewModel: ServersViewModel

    init(appViewState: AppViewState) {
        UIApplication.shared.setupApperance()
        self.mainAppModel = appViewState.homeViewModel
        self.appViewState = appViewState
        self.homeViewModel = HomeViewModel(appViewState: appViewState)
        self.settingsViewModel = SettingsViewModel(mainAppModel: appViewState.homeViewModel)
        self.serversViewModel = ServersViewModel(mainAppModel: appViewState.homeViewModel)
    }
    
    var body: some View {
        ZStack {
            
            contentView
            
            DragView(isPresented: $sheetManager.isPresented,
                     presentationType: .show,
                     backgroundColor: sheetManager.backgroundColor,
                     tapToDismiss: sheetManager.shouldHideOnTap) {
                sheetManager.content
            }
            securityScreenView
            
        }
    }
    
    private var contentView: some View {
        CustomNavigation() {
            ZStack {
                
                tabbarContentView
                
                if mainAppModel.selectedTab == .mic {
                    RecordView(mainAppModel: mainAppModel,
                               sourceView: .tab,
                               showingRecoredrView: .constant(true))
                }
                
                if mainAppModel.selectedTab == .camera {
                    CameraView(sourceView: .tab,
                               showingCameraView: .constant(true),
                               mainAppModel: mainAppModel)
                }
            }
        }.accentColor(.white)
    }
    
    var tabbarContentView: some View {
        
        TabView(selection: $mainAppModel.selectedTab) {
            HomeView(viewModel: self.homeViewModel)
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
            
            SettingsMainView(appViewState: appViewState,
                             settingsViewModel: SettingsViewModel(mainAppModel: mainAppModel),
                             serversViewModel: ServersViewModel(mainAppModel: mainAppModel))
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

//struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(mainAppModel: MainAppModel.stub())
//            .preferredColorScheme(.light)
//            .previewLayout(.device)
//            .previewDevice("iPhone 8")
//    }
//}
//
