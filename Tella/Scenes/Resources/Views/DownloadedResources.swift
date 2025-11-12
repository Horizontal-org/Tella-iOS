//
//  DownloadedResources.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct DownloadedResources: View {
    @EnvironmentObject var sheetManager: SheetManager
    @ObservedObject var viewModel: ResourcesViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: LocalizableResources.resourcesDownloadedTitle.localized)
            if viewModel.downloadedResources.isEmpty && viewModel.availableResources.isEmpty {
                emptyView            }
            else if viewModel.downloadedResources.isEmpty {
                emptyDownloadedResources
            } else {
                downloadedResourcesContent
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            viewModel.onShowResourceBottomSheet = {
                self.showResourceBottomSheet()
            }
        }
    }
    
    private var emptyView: some View {
        SectionMessage(text: LocalizableResources.resourcesDownloadedSecondMsg.localized)
    }
    
    private var emptyDownloadedResources: some View {
        SectionMessage(text: LocalizableResources.resourcesDownloadedEmpty.localized)
    }
    
    private var downloadedResourcesContent: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.downloadedResources) { resource in
                    ResourceCardView(isLoading: false, resourceCard: resource).onTapGesture {
                        resource.onTap()
                        navigateToPDFView()
                    }
                }
            }
        }.frame(maxHeight: CGFloat(viewModel.downloadedResources.count) * 90)
    }
    
    private func showResourceBottomSheet() {
        sheetManager.showBottomSheet() {
            ActionListBottomSheet(items: ResourceActionItems, headerTitle: viewModel.selectedResource?.title ?? "", action: { item in
                    let type = item.type as? ResourceActionType
                    if type == .delete {
                        showDeleteResourceConfirmationView()
                    } else {
                        navigateToPDFView()
                    }
                })
        }
    }
    
    private func showDeleteResourceConfirmationView() {
        sheetManager.showBottomSheet() {
            return ConfirmBottomSheet(titleText: LocalizableResources.resourcesDownloadRemoveSheetTitle.localized,
                                      msgText: LocalizableResources.resourcesDownloadRemoveSheetExpl.localized,
                                      cancelText: LocalizableResources.resourcesDownloadRemoveCancelSheetAction.localized,
                                      actionText: LocalizableResources.resourccesDownloadRemoveConfirmSheetAction.localized) {
                viewModel.deleteResource(resourceId: viewModel.selectedResource?.id ?? "")
                Toast.displayToast(message: "“\(viewModel.selectedResource?.title ?? "")” \(LocalizableResources.resourcesDownloadRemoveToast.localized)")
            }
        }
    }
    
    private func navigateToPDFView() {
        if let file = viewModel.openResource() {
            navigateTo(destination: ResourcePDFView(file: file, resourceTitle: viewModel.selectedResource?.title ?? ""))
        }
        sheetManager.hide()
    }
}

#Preview {
    DownloadedResources(viewModel: ResourcesViewModel.stub())
}
