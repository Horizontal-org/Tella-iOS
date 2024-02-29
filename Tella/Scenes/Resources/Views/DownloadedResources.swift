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
    @ObservedObject var viewModel: DownloadedResourcesVM
    var body: some View {
        VStack {
            SectionTitle(text: LocalizableResources.resourcesDownloadedTitle.localized)
            if viewModel.downloadedResources.isEmpty {
                SectionMessage(text: LocalizableResources.resourcesDownloadedEmpty.localized)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.downloadedResources) { resource in
                            ResourceCard(isLoading: false,
                                         title: resource.title,
                                         serverName: resource.serverName,
                                         type: .more,
                                         action: {showResourceBottomSheet(resourceTitle: resource.title, resourceId: resource.id)})
                        }
                    }
                }.frame(maxHeight: CGFloat(viewModel.downloadedResources.count) * 90)
            }
        }.padding(.bottom, 24)

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
    DownloadedResources(viewModel: DownloadedResourcesVM(mainAppModel: MainAppModel.stub()))
}
