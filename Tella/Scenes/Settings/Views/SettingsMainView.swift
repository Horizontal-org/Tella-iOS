//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsMainView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var appViewState : AppViewState
    
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var settingsViewModel : SettingsViewModel
    @StateObject var serversViewModel : ServersViewModel
    
    init(appModel:MainAppModel) {
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appModel: appModel))
        _serversViewModel = StateObject(wrappedValue: ServersViewModel(mainAppModel: appModel))
    }
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onDisappear {
            appModel.publishUpdates()
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
                            GeneralView().environmentObject(settingsViewModel))
    }
    
    
    
    var securityView: some View {
        SettingsItemView(imageName: "settings.lock",
                         title: LocalizableSettings.settSecAppBar.localized,
                         destination:securitySettingsView)
    }
    
    var serversView: some View {
        let viewModel = ServersViewModel(mainAppModel: appModel)

        return SettingsItemView(imageName: "settings.servers",
                         title: LocalizableSettings.settConnections.localized,
                         destination:ServersListView(serversViewModel:viewModel ))
                              
    }
    
    var helpView: some View {
        SettingsItemView(imageName: "settings.help",
                         title: LocalizableSettings.settAbout.localized,
                         destination:AboutAndHelpView().environmentObject(settingsViewModel))
    }
    
    var securitySettingsView: SecuritySettingsView {
        SecuritySettingsView(appModel: MainAppModel.stub(), appViewState: appViewState, settingsViewModel:settingsViewModel)
    }
    
    var feedbackView: some View {
        SettingsItemView(imageName: "settings.feedback",
                         title: LocalizableSettings.settFeedback.localized,
                         presentationType: .present,
                         destination:
                            FeedbackView(mainAppModel: appModel)
            .environmentObject(appModel)
            .environmentObject(sheetManager))
    }
    
}
struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appModel: MainAppModel.stub())
    }
}
