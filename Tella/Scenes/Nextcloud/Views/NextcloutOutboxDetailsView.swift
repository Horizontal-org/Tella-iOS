//
//  NextcloutOutboxView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/8/2024.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct NextcloutOutboxDetailsView<T: NextcloudServer>: View {
    
    @StateObject var outboxReportVM : NextcloudOutboxViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM, rootView: ViewClassType.nextcloudReportMainView)
            .onReceive(outboxReportVM.$shouldShowLoginView, perform: { shouldShowLogin in
                if shouldShowLogin {
                    showLoginConfirmationView()
                }
            })
    }
    
    private func showLoginConfirmationView() {
        sheetManager.showBottomSheet() {
            ConfirmBottomSheet(imageName:"nextcloud.icon",
                               titleText: LocalizableNextcloud.connectionExpiredTitle.localized,
                               msgText: LocalizableNextcloud.connectionExpiredExpl.localized,
                               cancelText: LocalizableNextcloud.connectionExpiredContinue.localized.uppercased(),
                               actionText:LocalizableNextcloud.connectionExpiredLogin.localized.uppercased(), didConfirmAction: {
                sheetManager.hide()
                navigateToLoginView()
            }, didCancelAction: {
                sheetManager.hide()
            })
        }
    }
    
    func navigateToLoginView() {
        guard let server = outboxReportVM.reportViewModel.server else { return  }
        let nextcloudVM = NextcloudServerViewModel(mainAppModel: outboxReportVM.mainAppModel,
                                                   currentServer: server)
        navigateTo(destination: NextcloudLoginView(nextcloudVM: nextcloudVM))
    }
}
