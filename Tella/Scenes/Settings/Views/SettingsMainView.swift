//
//  SettingsMainView.swift
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsMainView: View {
    
    @ObservedObject var appModel : MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var settingsViewModel : SettingsViewModel
    
    init(appModel:MainAppModel) {
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appModel: appModel))
        self.appModel = appModel
    }
    
    var body: some View {
        ContainerView {
            VStack( spacing: 12) {
                if appModel.shouldUpdateLanguage {
                    Spacer()
                        .frame(height: 12)
                    GeneralSettingsView()
                        .environmentObject(settingsViewModel)
                    RecentFilesSettingsView()
                    ScreenSecuritySettingsView()
                    Spacer()
                }
            } .padding(EdgeInsets(top: 0, leading: 17, bottom: 0, trailing: 17))
            
        }
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.appBar.localized)
        }
        
        .onDisappear(perform: {
            appModel.saveSettings()
        })
        
        .onDisappear {
            appModel.publishUpdates()
        }
    }
}

struct GeneralSettingsView : View {
    
    @State private var presentingLanguage = false
    @EnvironmentObject var appModel : MainAppModel
    @StateObject var lockViewModel = LockViewModel(unlockType: .update)
    @EnvironmentObject private var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body : some View {
        
        VStack(spacing: 0) {
            
            SettingsItemView(imageName: "settings.language",
                             title: LocalizableSettings.settLanguage.localized,
                             value: LanguageManager.shared.currentLanguage.name)
            .onTapGesture {
                presentingLanguage = true
            }
            
            DividerView()
            
            SettingsItemView(imageName: "settings.lock",
                             title: LocalizableSettings.settLock.localized)
            
            .navigateTo(destination: unlockView)
            
            
            DividerView()
            
            SettingsItemView(imageName: "settings.timeout",
                             title: LocalizableSettings.settLockTimeout.localized,
                             value: appModel.settings.lockTimeout.displayName)
            .onTapGesture {
                showLockTimeout()
            }
            
            DividerView()
            
            SettingsItemView(imageName: "settings.help",
                             title: LocalizableSettings.settAbout.localized,
                             value: "")
            .navigateTo(destination: AboutAndHelpView()
                .environmentObject(settingsViewModel))
            
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .fullScreenCover(isPresented: $presentingLanguage) {
                
            } content: {
                LanguageListView(isPresented: $presentingLanguage)
            }
            .onAppear {
                lockViewModel.shouldDismiss.send(false)
            }
    }
    
    var unlockView : some View {
        UnlockPinView()
            .environmentObject(lockViewModel)
            .eraseToAnyView()
    }
    
    func showLockTimeout() {
        sheetManager.showBottomSheet(modalHeight: 408) {
            LockTimeoutView()
                .environmentObject(settingsViewModel)
        }
    }
}

struct RecentFilesSettingsView : View {
    
    @EnvironmentObject var appModel : MainAppModel
    
    var body : some View {
        
        
        SettingToggleItem(title: LocalizableSettings.settRecentFiles.localized,
                          description: LocalizableSettings.settRecentFilesExpl.localized,
                          toggle: $appModel.settings.showRecentFiles)
        
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
    }
}


struct ScreenSecuritySettingsView : View {
    
    @EnvironmentObject var appModel : MainAppModel
    
    var body : some View {
        
        SettingToggleItem(title: LocalizableSettings.settScreenSecurity.localized,
                          description: LocalizableSettings.settScreenSecurityExpl.localized,
                          toggle: $appModel.settings.screenSecurity)
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
    }
}

struct DividerView : View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color.white.opacity(0.2))
    }
    
}

struct SettingsItemView : View {
    
    var imageName : String = ""
    var title : String = ""
    var value : String = ""
    
    var body : some View {
        
        HStack {
            Image(imageName)
            Spacer()
                .frame(width: 10)
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
            
        }.padding(.all, 18)
            .contentShape(Rectangle())
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appModel: MainAppModel())
    }
}
