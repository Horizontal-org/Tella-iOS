//
//  GdriveOutboxDetailsView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
struct GdriveOutboxDetailsView<T: GDriveServer>: View {
    
    @StateObject var outboxReportVM : GDriveOutboxViewModel
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM, rootView: ViewClassType.gdriveReportMainView)
            .onReceive(outboxReportVM.$shouldShowCreateFolder, perform: { shouldShowCreateFolder in
                if shouldShowCreateFolder {
                    showCreateFolderBottomSheet()
                }
            })
        
    }
    
    func showCreateFolderBottomSheet() {
        let content = ConfirmBottomSheet(imageName: "gdrive.icon",
                                         titleText: LocalizableSettings.createNewFolderSheetTitle.localized,
                                         msgText: LocalizableSettings.createNewFolderSheetExpl.localized,
                                         cancelText: LocalizableSettings.ceateNewFolderCancel.localized,
                                         actionText: LocalizableSettings.ceateNewFolder.localized,
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            self.dismiss {
                showCreateDriveFolderView()
            }
        })
        
        showBottomSheetView(content: content)
    }
    
    func showCreateDriveFolderView() {
        let gDriveServerVM = GDriveServerViewModel(repository: GDriveRepository(),
                                                   mainAppModel: outboxReportVM.mainAppModel,
                                                   serversSourceView: .outbox)
        navigateTo(
            destination: CreateDriveFolderView(gDriveServerViewModel: gDriveServerVM,
                                               shouldUpdateServer: { server in
                                                   outboxReportVM.updateServer(server: server)
                                               })
        )
    }
}

