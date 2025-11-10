//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsMainView: View {
    
    var appViewState : AppViewState
    var settingsViewModel : SettingsViewModel
    var serversViewModel : ServersViewModel
    
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onDisappear {
            appViewState.homeViewModel.publishUpdates()
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settAppBar.localized,
                             backButtonType: .none)
    }
    
    var contentView: some View {
        VStack(spacing:0) {
            
            Spacer()
                .frame(height: 8)
            
            SettingsCardView(cardViewArray: [generalView.eraseToAnyView(),
                                             securityView.eraseToAnyView(),
                                             serversView.eraseToAnyView(),
                                             helpView.eraseToAnyView()])
            
            SettingsCardView(cardViewArray: [feedbackView.eraseToAnyView()])
            
            Spacer()
        }
    }
    
    var generalView: some View {
        SettingsItemView(imageName: "settings.general",
                         title: LocalizableSettings.settGenAppBar.localized,
                         destination:
                            GeneralView(settingsViewModel: settingsViewModel,
                                        appViewState: appViewState))
    }
    
    var securityView: some View {
        SettingsItemView(imageName: "settings.lock",
                         title: LocalizableSettings.settSecAppBar.localized,
                         destination:securitySettingsView)
    }
    
    var serversView: some View {
        let viewModel = ServersViewModel(mainAppModel: appViewState.homeViewModel)
        
        return SettingsItemView(imageName: "settings.servers",
                                title: LocalizableSettings.settConnections.localized,
                                destination:ServersListView(serversViewModel:viewModel ))
        
    }
    
    var helpView: some View {
        SettingsItemView(imageName: "settings.help",
                         title: LocalizableSettings.settAbout.localized,
                         destination:AboutAndHelpView())
    }
    
    var securitySettingsView: SecuritySettingsView {
        let lockViewModel =  LockViewModel(unlockType: .update, appViewState: appViewState)
        
        return SecuritySettingsView(appModel: appViewState.homeViewModel,
                                    settingsViewModel: settingsViewModel,
                                    lockViewModel: lockViewModel)
    }
    
    var feedbackView: some View {
        
        let feedbackViewModel = FeedbackViewModel(mainAppModel: appViewState.homeViewModel)
        
        return SettingsItemView(imageName: "settings.feedback",
                                title: LocalizableSettings.settFeedback.localized,
                                presentationType: .present,
                                destination:
                                    FeedbackView(appModel: appViewState.homeViewModel,
                                                 feedbackViewModel: feedbackViewModel))
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appViewState: AppViewState.stub(),
                         settingsViewModel: SettingsViewModel.stub(),
                         serversViewModel: ServersViewModel.stub())
    }
}
