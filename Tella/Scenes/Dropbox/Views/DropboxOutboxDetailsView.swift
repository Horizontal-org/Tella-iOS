//
//  DropboxOutboxDetailsView.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DropboxOutboxDetailsView<T: DropboxServer>: View {
    @StateObject var outboxReportVM: DropboxOutboxViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM, rootView: ViewClassType.dropboxReportMainView)
            .onReceive(outboxReportVM.$shouldShowLoginView, perform: { shouldShowLogin in
                if shouldShowLogin {
                    showLoginConfirmationView()
                }
            })
            .onOpenURL { url in
                outboxReportVM.handleURLRedirect(url: url)
            }
    }
    
    private func showLoginConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 327) {
            ConfirmBottomSheet(imageName:"dropbox.icon",
                               titleText: LocalizableDropbox.connectionExpiredTitle.localized,
                               msgText: LocalizableDropbox.connectionExpiredExpl.localized,
                               cancelText: LocalizableDropbox.connectionExpiredContinue.localized.uppercased(),
                               actionText:LocalizableDropbox.connectionExpiredLogin.localized.uppercased(), didConfirmAction: {
                sheetManager.hide()
                outboxReportVM.reAuthenticateConnection()
            }, didCancelAction: {
                sheetManager.hide()
            })
        }
    }
}
