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
    @StateObject var viewModel : MainViewModel
    
    init(mainAppModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: MainViewModel(appModel: mainAppModel))
        setupApperance()
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
            
        }.navigationBarHidden(false)
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
        
        
        .navigationBarTitle(appModel.selectedTab == .home ? LocalizableHome.appBar.localized : "", displayMode: .inline)
        
        .if(appModel.selectedTab == .home, transform: { view in
            view.toolbar {
                homeToolbar
            }
        })
        .if(appModel.selectedTab == .settings, transform: { view in
            view.toolbar {
                settingsToolbar
            }
        })
        
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
    
    @ToolbarContentBuilder
    private var homeToolbar : some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button() {
                showTopSheetView(content: BackgroundActivitiesView(mainAppModel: appModel))
            } label: {
                Image(viewModel.items.count > 0 ? "home.notification_badge" : "home.notificaiton")
                    .padding()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.items.count > 0 ? showBgEncryptionConfirmationView() : appViewState.resetToUnlock()
            } label: {
                Image("home.close")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
        }
    }

    private func showBgEncryptionConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: LocalizableBackgroundActivities.exitSheetTitle.localized,
                               msgText: LocalizableBackgroundActivities.exitSheetExpl.localized,
                               cancelText: LocalizableBackgroundActivities.exitcancelSheetAction.localized,
                               actionText: LocalizableBackgroundActivities.exitDiscardSheetAction.localized, didConfirmAction: {
                appViewState.resetToUnlock()
                sheetManager.hide()
            })
        }
    }

    @ToolbarContentBuilder
    private var settingsToolbar : some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text(LocalizableSettings.settAppBar.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
                .frame(width: 260,height:25,alignment:.leading)
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
