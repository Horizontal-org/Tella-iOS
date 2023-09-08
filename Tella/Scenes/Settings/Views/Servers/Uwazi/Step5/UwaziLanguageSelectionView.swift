//
//  UwaziLanguageSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziLanguageSelectionView: View {
    @Binding var isPresented : Bool
    @EnvironmentObject var uwaziServerViewModel: UwaziServerViewModel
    @EnvironmentObject var serversViewModel: ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    headerView()
                    listView()
                    Spacer()
                    Rectangle().frame(height: 0.4).foregroundColor(.white)
                    bottomView()
                }
                if uwaziServerViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .onAppear(perform: {
            self.uwaziServerViewModel.languages.removeAll()
            self.uwaziServerViewModel.getLanguage()
        })
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.UwaziLanguageTitle.localized)
        }
    }
    fileprivate func bottomView() -> some View {
        return HStack{
            Spacer()
            SettingsBottomView(cancelAction: {
                self.presentationMode.wrappedValue.dismiss()
            }, saveAction: {
                uwaziServerViewModel.handleServerAction()
                navigateTo(destination: UwaziSuccessView())

            }, saveActionTitle: "OK")
        }
        .padding(.trailing, 20)
        .padding(.top, 12)
    }

    fileprivate func headerView() -> some View {
        return VStack {
            Spacer()
                .frame(height: 20)
            Text(LocalizableSettings.UwaziLanguageMessage.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .opacity(0.88)
                .multilineTextAlignment(.center)
                .padding(.trailing, 20)
                .padding(.leading, 20)
        }
    }

    fileprivate func listView() -> some View {
        return List {
            ForEach(uwaziServerViewModel.languages, id:\.self) { item in
                UwaziLanguageItemView(languageItem: item,
                                      selectedLanguage: $uwaziServerViewModel.selectedLanguage,
                                      isPresented: $isPresented)
            }.listRowBackground(Color.red)
        }
        .listStyle(.plain)
        .overlay(Group {
            if(uwaziServerViewModel.languages.isEmpty) {
                ZStack() {
                    Styles.Colors.backgroundMain
                        .edgesIgnoringSafeArea(.all)
                }
            }
        })
    }
}
struct UwaziLanguageItemView : View {

    var languageItem : UwaziLanguageRow?
    @Binding var selectedLanguage: UwaziLanguageRow?

    @Binding var isPresented : Bool
    @EnvironmentObject private var appModel: MainAppModel
    var delayTime = 0.1

    var body: some View {

        ZStack {

            HStack {
                VStack(alignment: .leading) {
                    Text(languageItem?.languageName ?? "")
                        .font(.custom(Styles.Fonts.regularFontName, size: 15))
                        .foregroundColor(.white)

                    Text(languageItem?.languageName ?? "")
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
                        .foregroundColor(.white)
                }
                Spacer()
                if isCurrentLanguage(languageItem: languageItem) {
                    Image("settings.done")
                }

            }
            Button("") {
                selectedLanguage = languageItem
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                    isPresented = false
                }
            }

        }.padding(EdgeInsets(top: 7, leading: 20, bottom: 11, trailing: 16))
            .frame(height: 70)
            .listRowBackground(isCurrentLanguage(languageItem: languageItem) ? Color.white.opacity(0.15) : Color.clear )
            .listRowInsets(EdgeInsets())
    }

    func isCurrentLanguage(languageItem: UwaziLanguageRow?) -> Bool {
        guard let languageItem = languageItem else { return false }
        if let selectedLanguage = selectedLanguage {
            return selectedLanguage.id == languageItem.id
        } else {
            return false
        }
    }
}

struct UwaziLanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(SettingsViewModel(appModel: MainAppModel.stub()))
    }
}

