//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AboutAndHelpView: View {
    var body: some View {
        ContainerView {
            VStack() {
                Spacer()
                    .frame(height: 60)
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                Spacer()
                    .frame(height: 19)
                
                Text(Localizable.Settings.settAboutHead)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                    .foregroundColor(.white)
                
                Text("\(Localizable.Settings.settAboutSubhead) \(Bundle.main.versionNumber)")

                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 24)
                
                AboutAndHelpItemsView()
                
                Spacer()
            }
        }
        .toolbar {
            LeadingTitleToolbar(title: Localizable.Settings.settAbout)
        }
    }
}

struct AboutAndHelpItemsView : View {
    
    @StateObject var settingsViewModel = SettingsViewModel()
    
    var body : some View {
        
        VStack(spacing: 0) {
            
            ForEach(0..<settingsViewModel.aboutAndHelpItems.count, id:\.self ) { i in
                let item = settingsViewModel.aboutAndHelpItems[i]
                
                Link(destination: URL(string: item.url)!) {
                    AboutAndHelpItemView(imageName: item.imageName,
                                         title: item.title)
                }
                
                
                if i <  settingsViewModel.aboutAndHelpItems.count - 1 {
                    DividerView()
                }
            }
            
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding()
    }
    
    
}

struct AboutAndHelpItemView : View {
    
    var imageName : String = ""
    var title : String = ""
    
    var body : some View {
        
        HStack {
            Image(imageName)
            Spacer()
                .frame(width: 10)
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.all, 20)
        .contentShape(Rectangle())
    }
}

struct AboutAndHelpView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAndHelpView()
    }
}


