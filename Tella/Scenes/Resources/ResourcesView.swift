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
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var contentView: some View {
        
        VStack {
            DownloadedResources()
                .environmentObject(resourcesViewModel)
            
            AvailableResources()
                .environmentObject(resourcesViewModel)
            
            Spacer()
            
        }.padding(.horizontal, 18)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableResources.resourcesServerTitle.localized,
                             backButtonAction: {backAction()},
                             trailingButton: .reload,
                             trailingButtonAction: { resourcesViewModel.getAvailableForDownloadResources() })
    }
    
    private func backAction() {
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
