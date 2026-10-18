//
//  UwaziLanguageSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/25/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziLanguageSelectionView: View {
    @Binding var isPresented : Bool
    @StateObject var uwaziServerViewModel: UwaziServerViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            if uwaziServerViewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
        .onAppear(perform: {
            self.uwaziServerViewModel.languages.removeAll()
            self.uwaziServerViewModel.getLanguage()
        })
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.UwaziLanguageTitle.localized)
    }

    var contentView: some View {
        VStack {
            headerView()
            listView()
            Spacer()
            Rectangle().frame(height: 0.4).foregroundColor(.white)
            bottomView()
        }
    }

    fileprivate func bottomView() -> some View {
        SettingsBottomView(cancelAction: {
            self.presentationMode.wrappedValue.dismiss()
        }, saveAction: {
            uwaziServerViewModel.handleServerAction()

            if uwaziServerViewModel.serversSourceView == .onboarding {
                self.popTo(ViewClassType.serverOnboardingView)
            } else {
                navigateTo(destination: UwaziSuccessView())
            }
        }, saveActionTitle: LocalizableSettings.UwaziLanguageOk.localized,
           isDisable: uwaziServerViewModel.selectedLanguage == nil)
        .padding(.top, 12)
    }
    
    fileprivate func headerView() -> some View {
        return VStack {
            Spacer()
                .frame(height: 20)
            CustomText(LocalizableSettings.UwaziLanguageMessage.localized,
                       style: .body1Style,
                       alignment: .center)
                .opacity(0.88)
                .padding(.trailing, 20)
                .padding(.leading, 20)
        }
    }
    
    fileprivate func listView() -> some View {
        return List {
            ForEach(uwaziServerViewModel.languages, id:\.locale) { item in
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

    var delayTime = 0.1
    
    var body: some View {
        
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    CustomText(languageItem?.translatedLanguageName ?? "",
                               style: .body1Style)

                    CustomText(languageItem?.languageName ?? "",
                               style: .body2Style)
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
            return selectedLanguage.locale == languageItem.locale
        } else {
            return false
        }
    }
}

struct UwaziLanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLanguageSelectionView(isPresented: .constant(true),
                                   uwaziServerViewModel: UwaziServerViewModel.stub())
    }
}

