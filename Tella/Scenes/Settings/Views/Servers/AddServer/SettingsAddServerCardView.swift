//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsAddServerCardView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var settingViewModel: SettingsViewModel
    
    var body: some View {
        ZStack {
            HStack{
                VStack(alignment: .leading, spacing: 2) {
                    
                    CustomText(LocalizableSettings.settAddConnection.localized,
                               style: .body1Style,
                               alignment: .leading)
                    
                    CustomText(LocalizableSettings.settAddConnectionExpl.localized,
                               style: .buttonDetailRegularStyle,
                               alignment: .leading)
                    
                    Button {
                        TellaUrls.connectionLearnMore.url()?.open()
                    } label: {
                        CustomText(LocalizableSettings.settAddConnectionLearnMore.localized,
                                   style: .buttonDetailRegularStyle,
                                   alignment: .leading,
                                   color: Styles.Colors.yellow)
                    } 
                }
                
                Spacer()
                
                Button {
                    navigateTo(destination: ServerSelectionView(appModel: serversViewModel.mainAppModel,
                                                                serversViewModel: serversViewModel).environmentObject(serversViewModel))
                } label: {
                    Image("settings.add")
                        .padding(.all, 14)
                }
            }
        }
        
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0))
        .environmentObject(serversViewModel)
    }
    
    var addServerURLView: some View {
        TellaWebAddServerURLView(appModel: serversViewModel.mainAppModel)
    }
}

struct SettingsAddServerCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAddServerCardView()
            .environmentObject(TellaWebServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
