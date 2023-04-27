//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsAddServerCardView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var settingViewModel: SettingsViewModel
    
    var body: some View {
        ZStack {
            HStack{
                VStack(alignment: .leading) {
                    Text("Servers")
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(Color.white).padding(.bottom, -5)
                    
                    Text("If you work with an organization, connect to its server to send files and data. Your organization should provide you with the server details.")
                        .foregroundColor(Color.white)
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
                }
                
                Spacer()
                
                Button {
                    navigateTo(destination: AddServerURLView(appModel: mainAppModel)  )
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
        AddServerURLView(appModel: mainAppModel)
    }
}

struct SettingsAddServerCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAddServerCardView()
    }
}
