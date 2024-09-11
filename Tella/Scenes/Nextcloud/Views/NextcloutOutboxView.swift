//
//  NextcloutOutboxView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct NextcloutOutboxView<T: NextcloudServer>: View {
    
    @StateObject var outboxReportVM : OutboxMainViewModel<T>
    @StateObject var reportsViewModel : ReportsMainViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel: MainAppModel
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM,
                          reportsViewModel: reportsViewModel, rootView: ViewClassType.nextcloudReportMainView)
        
        .onReceive(outboxReportVM.$shouldShowLoginView, perform: { shouldShowLogin in
            if shouldShowLogin {
                showLoginConfirmationView()
            }
        })
    }
    
    private func showLoginConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 327) {
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
        let nextcloudVM = NextcloudServerViewModel(mainAppModel: mainAppModel,currentServer: server)
        navigateTo(destination: NextcloudLoginView(nextcloudVM: nextcloudVM))
    }
}
