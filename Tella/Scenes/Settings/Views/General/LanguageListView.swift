//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct LanguageListView: View {
    
    @Binding var isPresented : Bool
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @EnvironmentObject private var appViewState: AppViewState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ContainerView {
            
            VStack {
                
                LanguageHeaderView(isPresented: $isPresented)
                
                List {
                    ForEach(settingsViewModel.languageItems, id:\.self) {item in
                        LanguageItemView(languageItem: item, settingsViewModel: settingsViewModel,
                                         isPresented: $isPresented)
                    }
                }
                .listStyle(.plain)
            }
        }
        .onReceive(appViewState.$shouldHidePresentedView) { value in
            if(value) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LanguageHeaderView : View {
    
    @Binding var isPresented : Bool
    
    var body: some View {
        
        HStack {
            Button {
                isPresented = false
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            
            Text(LocalizableSettings.settLangAppBar.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 20))
                .foregroundColor(Color.white)
            
            Spacer()
            
        }.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
    }
}

struct LanguageItemView : View {
    
    var languageItem : Language
    @StateObject var settingsViewModel :  SettingsViewModel
    
    @Binding var isPresented : Bool
    
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var appModel: MainAppModel
    
    var body: some View {
        
        ZStack {
            
            HStack {
                VStack(alignment: .leading) {
                    Text(languageItem.name)
                        .font(.custom(Styles.Fonts.regularFontName, size: 15))
                        .foregroundColor(.white)
                    
                    Text(languageItem.translatedName)
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if isCurrentLanguage(languageItem: languageItem) {
                    Image("settings.done")
                }
                
            }
            Button("") {
                updateLanguage()
            }
            
        }.padding(EdgeInsets(top: 7, leading: 20, bottom: 11, trailing: 16))
            .frame(height: 70)
            .listRowBackground(isCurrentLanguage(languageItem: languageItem) ? Color.white.opacity(0.15) : Color.clear )
            .listRowInsets(EdgeInsets())
    }
    
    func isCurrentLanguage(languageItem:Language) -> Bool {
        return (languageItem == LanguageManager.shared.currentLanguage)
    }
    
    func updateLanguage() {
        popToRoot(animated: false)
        LanguageManager.shared.currentLanguage = languageItem
        appViewState.mainAppLayout = LanguageManager.shared.currentLanguage.layoutDirection
        appViewState.homeViewModel.shouldUpdateLanguage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isPresented = false
        }
    }
}

struct LanguageListView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageListView(isPresented: .constant(true))
    }
}
