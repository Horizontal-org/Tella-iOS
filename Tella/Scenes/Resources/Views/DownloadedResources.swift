//
//  DownloadedResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DownloadedResources: View {
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var viewModel: ResourcesViewModel
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesDownloadedTitle.localized)
            if viewModel.downloadedResources.isEmpty && viewModel.availableResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesDownloadedSecondMsg.localized)
            }
            else if viewModel.downloadedResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesDownloadedEmpty.localized)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.downloadedResources) { resource in
                            ResourceCardView(isLoading: false, resourceCard: resource).onTapGesture {
                                navigateToPDFView(resourceId: resource.id, resourceTitle: resource.title)
                            }
                        }
                    }
                }.frame(maxHeight: CGFloat(viewModel.downloadedResources.count) * 90)
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            viewModel.onShowResourceBottomSheet = {  resourceId, resourceTitle in
                self.showResourceBottomSheet(resourceTitle: resourceTitle, resourceId: resourceId)
            }
        }
        

    }
    
    private func showResourceBottomSheet(resourceTitle: String, resourceId: String) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: ResourceActionItems, headerTitle: resourceTitle, action: { item in
                    let type = item.type as? ResourceActionType
                    if type == .delete {
                        showDeleteResourceConfirmationView(resourceTitle: resourceTitle, resourceId: resourceId)
                    } else {
                        navigateToPDFView(resourceId: resourceId, resourceTitle: resourceTitle)
                    }
                })
        }
    }
    
    private func showDeleteResourceConfirmationView(resourceTitle: String, resourceId: String) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: LocalizableResources.resourcesDownloadRemoveSheetTitle.localized,
                                      msgText: LocalizableResources.resourcesDownloadRemoveSheetExpl.localized,
                                      cancelText: LocalizableResources.resourcesDownloadRemoveCancelSheetAction.localized,
                                      actionText: LocalizableResources.resourccesDownloadRemoveConfirmSheetAction.localized) {
                viewModel.deleteResource(resourceId: resourceId)
                Toast.displayToast(message: "“\(resourceTitle)” \(LocalizableResources.resourcesDownloadRemoveToast.localized)")
            }
        }
    }
    
    private func navigateToPDFView(resourceId: String, resourceTitle: String) {
        if let file = viewModel.openResource(resourceId: resourceId, fileName: resourceTitle) {
            navigateTo(destination: ResourcePDFView(file: file, resourceTitle: resourceTitle))
        }
        sheetManager.hide()
    }
}

#Preview {
    DownloadedResources()
}
