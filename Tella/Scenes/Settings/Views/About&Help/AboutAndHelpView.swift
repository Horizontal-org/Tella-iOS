//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AboutAndHelpView: View {
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settAboutAppBar.localized)
    }
    
    var contentView: some View {
        VStack() {
            Spacer()
                .frame(height: 60)
            
            topView
            
            Spacer()
                .frame(height: 24)
            
            SettingsCardView(cardViewArray: [tutorialView.eraseToAnyView(),
                                             faqView.eraseToAnyView(),
                                             contactusView.eraseToAnyView(),
                                             privacyView.eraseToAnyView()])
            
            Spacer()
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
            
            Text("\(LocalizableSettings.settAboutSubhead.localized) \(Bundle.main.versionWithBuildNumber)")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
        }
    }
    
    var contactusView : some View {
        SettingsLinkItemView(imageName: "settings.contact-us",
                             title: LocalizableSettings.settAboutContactUs.localized,
                             linkURL: TellaUrls.contactURL)
    }
    
    var privacyView : some View {
        SettingsLinkItemView(imageName: "settings.privacy",
                             title: LocalizableSettings.settAboutPrivacyPolicy.localized,
                             linkURL: TellaUrls.privacyURL)
    }
    var faqView : some View {
        SettingsLinkItemView(imageName: "settings.help",
                             title: LocalizableSettings.settAboutPrivacyFaq.localized,
                             linkURL: TellaUrls.faq)
    }
    var tutorialView : some View {
        SettingsLinkItemView(imageName: "settings.info",
                             title: LocalizableSettings.settAboutPrivacyTutorial.localized,
                             linkURL: TellaUrls.tutorial)
    }
    
}

struct AboutAndHelpView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAndHelpView()
    }
}


