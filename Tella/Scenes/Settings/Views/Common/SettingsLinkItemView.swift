//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingsLinkItemView: View {
    
    var imageName : String
    var title : String
    var linkURL : String
    
    var body: some View {
        HStack{
            Link(destination: URL(string: linkURL)!) {
                HStack {
                    Image(imageName)
                    Spacer()
                        .frame(width: 10)
                    Text(title)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }.padding(.all, 18)
            }
        }
    }
}

struct SettingsLinkItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLinkItemView(imageName: "settings.contact-us",
                             title: LocalizableSettings.settAboutContactUs.localized,
                             linkURL: TellaUrls.contactURL)
    }
}

