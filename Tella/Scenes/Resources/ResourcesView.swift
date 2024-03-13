//
//  ResourcesView.swift
//  Tella
//
//  Created by gus valbuena on 1/31/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourcesView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var resourcesViewModel : ResourcesViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    init(mainAppModel: MainAppModel) {
        _resourcesViewModel = StateObject(wrappedValue: ResourcesViewModel(mainAppModel: mainAppModel))
    }

    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    resourceHeaderView
                    
                    VStack {
                        DownloadedResources()
                            .environmentObject(resourcesViewModel)

                        AvailableResources()
                            .environmentObject(resourcesViewModel)
                    }.padding(.top, 18)
                    
                    Spacer()
                }.padding(.horizontal, 18)
            }
        }
        .navigationBarHidden(true)
    }
    
    var resourceHeaderView: some View {
        HStack(spacing: 0) {
            backButton
            headerTitleView
            Spacer()
            reloadButton
        }.frame(height: 56)
    }
    
    private var backButton: some View {
        Button {
            backButtonAction()
        } label: {
            Image("back")
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 12))
        }
    }
    
    private var headerTitleView: some View {
        Text(LocalizableResources.resourcesServerTitle.localized)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }
    
    private var reloadButton: some View {
        Button(action: { resourcesViewModel.getAvailableForDownloadResources() }) {
            Image("arrow.clockwise")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    
    private func backButtonAction() {
        if !resourcesViewModel.availableResources.contains(where: { $0.isLoading }) {
            presentationMode.wrappedValue.dismiss()
        } else {
            exitResourceConfirmatinoBottomSheet()
        }
    }
    
    private func exitResourceConfirmatinoBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: LocalizableResources.resourceExitSheetTitle.localized,
                                      msgText: LocalizableResources.resourceExitSheetExpl.localized,
                                      cancelText: LocalizableResources.resourceExitCancelSheetSelect.localized,
                                      actionText: LocalizableResources.resourceExitConfirmSheetSelect.localized) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    ResourcesView(mainAppModel: MainAppModel.stub())
}
