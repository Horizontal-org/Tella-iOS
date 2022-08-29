//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AboutAndHelpView: View {
    
    var cards: [CardData<AnyView>]  = [CardData(imageName:"settings.contact-us",
                                                title: LocalizableSettings.settAboutContactUs.localized,
                                                linkURL: TellaUrls.contactURL,
                                                cardType : .link,
                                                cardName: AboutAndHelpCardName.contactUs, destination: nil),
                                       CardData(imageName: "settings.privacy",
                                                title: LocalizableSettings.settAboutPrivacyPolicy.localized,
                                                linkURL: TellaUrls.privacyURL,
                                                cardType : .link,
                                                cardName: AboutAndHelpCardName.privacy)]
    
    var body: some View {
        ContainerView {
            VStack() {
                Spacer()
                    .frame(height: 60)
                
                topView
                
                Spacer()
                    .frame(height: 24)
                
                SettingsCardView(cardDataArray: cards)
                
                Spacer()
            }
        }
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settAboutAppBar.localized)
        }
    }
    
    var topView : some View {
        VStack() {
            
            Image("tella.logo")
                .frame(width: 65, height: 72)
                .aspectRatio(contentMode: .fit)
            Spacer()
                .frame(height: 19)
            
            Text(LocalizableSettings.settAboutHead.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
            
            Text("\(LocalizableSettings.settAboutSubhead.localized) \(Bundle.main.versionNumber)")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
        }
    }
}


struct AboutAndHelpView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAndHelpView()
    }
}


