//
//  UwaziLanguageSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziLanguageSelectionView: View {
    @Binding var isPresented : Bool
    //@EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var serverViewModel: UwaziServerViewModel
    @EnvironmentObject var serversViewModel: ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showSuccessView = false

    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "arrow.backward")
                .font(.system(size: 18, weight: .bold))
                .aspectRatio(contentMode: .fill)
            Text(LocalizableSettings.UwaziLanguageTitle.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
        }
        .foregroundColor(Color.white)
        .opacity(0.8)
    }
    }
    var body: some View {
        ContainerView {

            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 20)
                    Text(LocalizableSettings.UwaziLanguageMessage.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                        .opacity(0.88)
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 20)
                        .padding(.leading, 20)
                    List {
                        ForEach(serverViewModel.languages, id:\.self) { item in
                            UwaziLanguageItemView(languageItem: item,
                                                  selectedLanguage: $serverViewModel.selectedLanguage,
                                                  //settingsViewModel: settingsViewModel,
                                                  isPresented: $isPresented)
                        }.listRowBackground(Color.red)
                    }
                    .listStyle(.plain)
                    .overlay(Group {
                        if(serverViewModel.languages.isEmpty) {
                            ZStack() {
                                Styles.Colors.backgroundMain
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                    })
                    Spacer()
                    Rectangle().frame(height: 0.4).foregroundColor(.white)
                    HStack{
                        Spacer()
                        LanguageActionButton(type: .cancel) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        LanguageActionButton(type: .ok) {
                            serverViewModel.handleServerAction()
                            navigateTo(destination: UwaziSuccessView())
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
                
            }

        }
        .onAppear(perform: {
            self.serverViewModel.languages.removeAll()
            self.serverViewModel.getLanguage()
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

struct LanguageActionButton: View {
    enum ButtonAction {
        case ok
        case cancel

        var title: String {
            switch self {
            case .ok:
                return LocalizableSettings.UwaziLanguageOk.localized
            case .cancel:
                return LocalizableSettings.UwaziLanguageCancel.localized
            }
        }
        var buttonColor: Color {
            switch self {
            case .ok:
                return Styles.Colors.yellow
            case .cancel:
                return Color(UIColor(hexValue: 0xF5F5F5).withAlphaComponent(0.16))
            }
        }
    }
    let type: ButtonAction
    var action: () -> Void

    var body: some View {
        Button(type.title,action: action).buttonStyle(BigButtonStyleForLanguage(color: type.buttonColor))
    }
}

struct UwaziLanguageItemView : View {

    var languageItem : UwaziLanguageRow
    @Binding var selectedLanguage: UwaziLanguageRow?
    //@StateObject var settingsViewModel :  SettingsViewModel

    @Binding var isPresented : Bool

    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var appModel: MainAppModel

    var body: some View {

        ZStack {

            HStack {
                VStack(alignment: .leading) {
                    Text(languageItem.languageName())
                        .font(.custom(Styles.Fonts.regularFontName, size: 15))
                        .foregroundColor(.white)

                    Text(languageItem.languageName())
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
                        .foregroundColor(.white)
                }

                Spacer()

                if isCurrentLanguage(languageItem: languageItem) {
                    Image("settings.done")
                }

            }
            Button("") {
               // LanguageManager.shared.currentLanguage = languageItem
                selectedLanguage = languageItem
                appModel.shouldUpdateLanguage = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPresented = false
                }
            }

        }.padding(EdgeInsets(top: 7, leading: 20, bottom: 11, trailing: 16))
            .frame(height: 70)
            .listRowBackground(isCurrentLanguage(languageItem: languageItem) ? Color.white.opacity(0.15) : Color.clear )
            .listRowInsets(EdgeInsets())
    }

    func isCurrentLanguage(languageItem: UwaziLanguageRow) -> Bool {
        if let selectedLanguage = selectedLanguage {
            return selectedLanguage.id == languageItem.id
        } else {
            return false
        }
    }
}

struct BigButtonStyleForLanguage: ButtonStyle {
    @State var color: Color = .red

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
            .padding()
            .frame(width: 120, height: 40)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(25)
    }
}

struct UwaziLanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(SettingsViewModel(appModel: MainAppModel.stub()))
    }
}

