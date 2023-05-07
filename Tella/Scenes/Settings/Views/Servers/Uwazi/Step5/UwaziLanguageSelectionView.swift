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
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var serverViewModel: ServerViewModel
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
                        ForEach(settingsViewModel.languageItems, id:\.self) { item in
                            LanguageItemView(languageItem: item, settingsViewModel: settingsViewModel,
                                             isPresented: $isPresented)
                        }
                    } .listStyle(.plain)
                Spacer()
                Rectangle().frame(height: 0.4).foregroundColor(.white)
                HStack{
                    Spacer()
                    LanguageActionButton(type: .cancel) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    LanguageActionButton(type: .ok) {
                        navigateTo(destination: UwaziSuccessView())
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 12)
            }

        }
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
            .environmentObject(SettingsViewModel(appModel: MainAppModel()))
    }
}

