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
                                         rightButtonImage: "reports.more",
                                         rightButtonAction: {showResourceBottomSheet(resourceTitle: resource.title, resourceId: resource.id)})
                        }
                    }
                }.frame(maxHeight: CGFloat(viewModel.downloadedResources.count) * 90)
            }
        }.padding(.bottom, 24)
        .sheet(isPresented: $viewModel.isOpenFile, onDismiss: {
            viewModel.pdfFile = nil
        }) {
            if let file = viewModel.pdfFile {
                // todo: add header
                QuickLookView(file: file)
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
                        viewModel.openResource(resourceId: resourceId, fileName: resourceTitle)
                        sheetManager.hide()
                    }
                })
        }
    }
    
    private func showDeleteResourceConfirmationView(resourceTitle: String, resourceId: String) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: "Remove from downloads",
                                      msgText: "Are you sure you want to remove this resource? You can always download it again",
                                      cancelText: "CANCEL",
                                      actionText: "REMOVE") {
                viewModel.deleteResource(resourceId: resourceId)
                Toast.displayToast(message: "“\(resourceTitle)” has been removed from your downloads")
            }
        }
    }
}

#Preview {
    DownloadedResources(viewModel: DownloadedResourcesVM(mainAppModel: MainAppModel.stub()))
}
