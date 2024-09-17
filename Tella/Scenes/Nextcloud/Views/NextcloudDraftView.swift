//
//  NextcloudDraftView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct NextcloudDraftView: View {
    
    @StateObject var nextcloudDraftViewModel: NextcloudDraftViewModel
    
    var body: some View {
        DraftView(viewModel: nextcloudDraftViewModel, showOutboxDetailsViewAction: {
            showOutboxDetailsView()
        })
    }
    
    private func showOutboxDetailsView() {
        let outboxVM = NextcloudOutboxViewModel(reportsViewModel: nextcloudDraftViewModel.reportsMainViewModel, reportId: nextcloudDraftViewModel.reportId, repository: nextcloudDraftViewModel.nextcloudRepository)
        navigateTo(destination:  NextcloutOutboxDetailsView(outboxReportVM: outboxVM))
        
    }
}

//#Preview {
//    NextcloudDraftView(mainAppModel: MainAppModel.stub(),
//                       nextcloudDIContainer: NextcloudDIContainer(),
//                       reportsViewModel: ReportsMainViewModel.stub())
//} //TOFIX
