//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsAddServerCardView: View {
    
    @StateObject var serversViewModel : ServersViewModel
    
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
                    navigateTo(destination: ServerSelectionView(serversViewModel: serversViewModel))
                } label: {
                    Image("settings.add")
                        .padding(.all, 14)
                }
            }
        }
        
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0))
    }
    
}

//struct SettingsAddServerCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsAddServerCardView()
//    }
//}
