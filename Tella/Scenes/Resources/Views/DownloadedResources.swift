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
            viewModel.onShowResourceBottomSheet = {
                self.showResourceBottomSheet()
            }
        }
        

    }
    
    private func showResourceBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: ResourceActionItems, headerTitle: viewModel.selectedResource?.title ?? "", action: { item in
                    let type = item.type as? ResourceActionType
                    if type == .delete {
                        showDeleteResourceConfirmationView()
                    } else {
                        navigateToPDFView(resourceId: viewModel.selectedResource?.id ?? "", resourceTitle: viewModel.selectedResource?.title ?? "")
                    }
                })
        }
    }
    
    private func showDeleteResourceConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: LocalizableResources.resourcesDownloadRemoveSheetTitle.localized,
                                      msgText: LocalizableResources.resourcesDownloadRemoveSheetExpl.localized,
                                      cancelText: LocalizableResources.resourcesDownloadRemoveCancelSheetAction.localized,
                                      actionText: LocalizableResources.resourccesDownloadRemoveConfirmSheetAction.localized) {
                viewModel.deleteResource(resourceId: viewModel.selectedResource?.id ?? "")
                Toast.displayToast(message: "“\(viewModel.selectedResource?.title ?? "")” \(LocalizableResources.resourcesDownloadRemoveToast.localized)")
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
