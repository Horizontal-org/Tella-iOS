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
                VStack(alignment: .leading) {
                    Text(LocalizableSettings.settConnections.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(Color.white).padding(.bottom, -5)
                    
                    Text("If you work with an organization, connect to its server to send files and data. Your organization should provide you with the server details.")
                        .foregroundColor(Color.white)
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
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
